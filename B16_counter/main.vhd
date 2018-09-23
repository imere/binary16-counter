-- 16位2进制计数器
-- 主文件
-- 调用库ieee
LIBRARY ieee;
-- 使用ieee库下 std_logic_1164包的 所有定义
USE ieee.std_logic_1164.all;
-- 使用ieee库下 std_logic_arith包的 所有定义
USE ieee.std_logic_arith.all;
-- 使用ieee库下 std_logic_unsigned包的 所有定义
USE ieee.std_logic_unsigned.all;

-- 使用work(当前工程文件中) jmp_config包的 MAX_COUNT定义
USE work.jmp_config.MAX_COUNT;
-- 使用work(当前工程文件中) counter_config包的 UNIT_COUNT定义
USE work.counter_config.UNIT_COUNT;

-- 定义实体main
ENTITY main IS
	-- 定义端口
	PORT(
		-- s1 复位
		-- s2 0.1s, 1s, 3s切换
		-- 低电有效
		s1, s2				  : IN std_logic;
		-- 50MHz时钟输入
		clk					  : IN std_logic;
		-- ym_38(6数码管)输入源
		sel					  : OUT std_logic_vector(2 DOWNTO 0);
		-- 单管(1数码管)输出
		seg					  : OUT std_logic_vector(0 TO (UNIT_COUNT - 1));
		-- led
		d						  : OUT std_logic_vector(3 DOWNTO 0)
	);
END ENTITY main;

-- 定义实体main的功能/架构arch
ARCHITECTURE arch OF main IS
	-- 引入元件led
	COMPONENT led IS
	-- 要引用的端口	名称,类型与引用元件保持一致
		PORT(
			s : IN std_logic;
			b : OUT std_logic_vector
		);
	END COMPONENT led;
	
	-- 引入元件jmp
	COMPONENT jmp IS
		PORT(
			clk								  : IN std_logic;
			sg1, sg2, sg3, sg4, sg5, sg6 : IN std_logic_vector;
			sg									  : OUT std_logic_vector;
			sel								  : OUT std_logic_vector
		);
	END COMPONENT jmp;
	
	-- 引入元件counter
	COMPONENT counter IS
		PORT(
			rst, clk : IN std_logic;
			co			: OUT std_logic;
			q			: OUT std_logic_vector(0 TO (UNIT_COUNT - 1))
		);
	END COMPONENT counter;
	
	-- 存储进位
	-- 此处为std_logic_vector类型, 共MAX_COUNT位
	SIGNAL carry										: std_logic_vector(0 TO (MAX_COUNT - 1));
	
	-- 存储单管输出
	SIGNAL sgo1, sgo2, sgo3, sgo4, sgo5, sgo6 : std_logic_vector((UNIT_COUNT - 1) DOWNTO 0);
	
	-- 分频系数变量
	-- 此处为integer类型, 范围为1-500000000, 初始值25000000
	SIGNAL modulus										: integer RANGE 1 TO 500000000 := 25000000;
	
	-- 存储分频系数变量 最终赋予分频系数变量
	SIGNAL md											: integer RANGE 1 TO 500000000 := 25000000;
	
	-- 单管计数时钟
	-- 此处为std_logic类型
	SIGNAL sp_clk										: std_logic;
	
	-- 扫描时钟
	SIGNAL j_clk										: std_logic;
	
	-- 全局计数完成标志
	-- 完成为1, 未完成为0
	SIGNAL flag											: std_logic;
BEGIN
	-- s2切换0.1s, 1s, 3s(分频系数)的进程
	prmd2:PROCESS(s2, md)
		-- 定义局部变量st	此处代表3个状态, 初始为1
		VARIABLE st : integer RANGE 0 TO 2 := 1;
	BEGIN
		-- s2为上升沿?
		-- 可用rising_edge(s2)代替; 若为下降沿可用falling_edge(s2)
		IF (s2'event and (s2 = '1')) THEN
			CASE st IS
				-- 状态0, 0.1s
				-- 由50MHz/1s得5MHz/0.1s, 即0.1s时钟周期5MHz, 半周期即2.5MHz, 一个时钟周期为 时钟连续两个高低电平占用时间 (时钟为方波)
				WHEN 0 => md <= 2500000;
				-- 状态1, 1s	
				WHEN 1 => md <= 25000000;
				-- 状态2, 3s	
				WHEN 2 => md <= 75000000;
			END CASE;
			-- s2处于 最后的 状态2?
			IF (st < 2) THEN
				-- 到下一个状态
				st := st + 1;
			ELSE
				-- 回到第一个状态
				st := 0;
			END IF;
		END IF;
		-- 把md赋予计数分频使用的modulus
		modulus <= md;
	END PROCESS prmd2;
	
	-- 单管计数分频
	prclk:PROCESS(clk)
		-- 定义分频局部变量cnt 范围:最大值不小于最大的modulus, 最小值不大于最小的modulus
		-- 若类似的范围不正确产生越界 会导致警告'pins are stuck at vcc or gnd'
		VARIABLE cnt : integer RANGE 0 TO 500000000 := 0;
	BEGIN
	-- clk为上升沿?
		IF (clk'event and (clk = '1')) THEN
			-- cnt + 1
			cnt := cnt + 1;
			IF (cnt >= modulus) THEN-------------------modulus应为时钟半周期
				-- cnt 置零
				cnt := 0;
				-- sp_clk翻转, 即'0'到'1', 或'1'到'0'
				sp_clk <= not sp_clk;
			END IF;-----------------------------------此段分频后时钟仍为方波
		END IF;
	END PROCESS prclk;
	
	-- 扫描/位选分频
	-- 此处时钟为50MHz时钟
	sclk:PROCESS(clk)
		-- 理论可为任意范围, 实际要保证位选过程不被人眼分辨
		VARIABLE cnt : integer RANGE 0 TO 500000000 := 0;
	BEGIN
		IF (clk'event and (clk = '1')) THEN
			cnt := cnt + 1;
			-- cnt > 20000?	理论可为在cnt定义范围内任意值, 实际要保证位选过程不被人眼分辨
			IF (cnt >= 20000) THEN
				cnt := 0;
				j_clk <= not j_clk;
			END IF;
		END IF;
	END PROCESS sclk;
	
	-- 用于全局计数
	-- 此处时钟sp_clk为分频后的计数时钟
	aclk:PROCESS(sp_clk, s1)
		-- 定义全局计数变量gcnt	最大为MAX
		VARIABLE gcnt : integer RANGE 0 TO work.global_config.MAX := 0;
	BEGIN
		IF (sp_clk'event and (sp_clk = '1')) THEN
			-- 置零键(s1)未按下 且 没有计到最大值MAX?
			IF ((s1 and not flag) = '1') THEN
				-- 全局计数+1
				gcnt := gcnt + 1;
			ELSE
				-- 全局计数置零
				gcnt := 0;
			END IF;
			-- gcnt达到最大值MAX?
			IF (gcnt >= work.global_config.MAX) THEN
				-- 完成标志置'1'
				flag <= '1';
				-- 由于完成, gcnt置零
				gcnt := 0;
			ELSE
				-- 完成标志置'0'
				flag <= '0';
			END IF;
		END IF;
	END PROCESS aclk;
	
	---------------------------------------------------- 元件例化
	-- 端口位置与引入时位置对应
	
	
	----此处置零判断逻辑参考全局计数-↓
	-- 第一位数码管	输出存sgo1      ↓
	-- 用分频后时钟sp_clk作时钟计数  ↓
	ct1  : counter PORT MAP(s1 and not flag, sp_clk, carry(0), sgo1);
	
	-- 第二位数码管	输出存sgo2
	-- 第一位数码管进位标志carry(0)作为第二个数码管的时钟
	ct2  : counter PORT MAP(s1 and not flag, carry(0), carry(1), sgo2);
	
	-- 第三位数码管	输出存sgo3
	-- 第二位数码管进位标志carry(1)作为第三个数码管的时钟
	ct3  : counter PORT MAP(s1 and not flag, carry(1), carry(2), sgo3);
	
	-- 第四位数码管	输出存sgo4
	-- 第三位数码管进位标志carry(2)作为第四个数码管的时钟
	ct4  : counter PORT MAP(s1 and not flag, carry(2), carry(3), sgo4);
	
	-- 第五位数码管	输出存sgo5
	-- 第四位数码管进位标志carry(3)作为第五个数码管的时钟
	ct5  : counter PORT MAP(s1 and not flag, carry(3), carry(4), sgo5);
	
	-- 第六位数码管	输出存sgo6
	-- 第五位数码管进位标志carry(4)作为第六个数码管的时钟
	-- 此处carry(5)无实际作用
	ct6  : counter PORT MAP(s1 and not flag, carry(4), carry(5), sgo6);
	
	-- 数码管位选
	-- 根据sel选择显示的数码管 输出对应的sgo(1-6)到seg
	jump : jmp PORT MAP(j_clk, sgo1, sgo2, sgo3, sgo4, sgo5, sgo6, seg, sel);
	
	-- 控制led
	l	  : led PORT MAP(not flag, d);
END ARCHITECTURE arch;