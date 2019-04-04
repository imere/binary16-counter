-- 单数码管输出/段选
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

-- 使用work(当前工程文件中) counter_config包的 所有定义
USE work.counter_config.all;

ENTITY counter IS
	PORT(
		-- rst 置零
		-- clk 应为分频后时钟
		rst, clk : IN std_logic;
		-- 进位输出
		co			: OUT std_logic;
		-- 对应UNIT_COUNT段数码管
		q			: OUT std_logic_vector(0 TO (UNIT_COUNT - 1))
	);
END ENTITY counter;

ARCHITECTURE arch OF counter IS
	-- 单管数字取值范围0-9, 可直接定义4位
	SIGNAL cnt : std_logic_vector(3 DOWNTO 0);
BEGIN
	count:PROCESS(rst, clk)
		BEGIN
		-- 置零键按下?
		IF (rst = '0') THEN
			-- 进位标志置'0'
			co <= '0';
			-- 单管计数置零
			cnt <= (OTHERS => '0');
		ELSIF (clk'event and (clk = '1')) THEN
			-- 计数+1
			cnt <= cnt + 1;
			-- 计数达到第MAX_SINGLE_COUNT个?
			IF (cnt >= (MAX_SINGLE_COUNT - 1)) THEN
				-- 进位标志置'1'
				co <= '1';
				-- 单管计数置零
				cnt <= (OTHERS => '0');
			ELSE
				-- 进位标志置'0'
				co <= '0';
			END IF;
		END IF;
	END PROCESS count;
	-- 根据cnt用函数outFix选择对应输出
	q <= outFix(cnt);
END ARCHITECTURE arch;