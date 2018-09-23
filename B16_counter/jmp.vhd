-- MAX_COUNT个数码管扫描/位选
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

-- 使用work(当前工程文件中) counter_config包的 UNIT_COUNT定义
USE work.counter_config.UNIT_COUNT;
-- 使用work(当前工程文件中) jmp_config包的 所有定义
USE work.jmp_config.all;

ENTITY jmp IS
	PORT(
		-- 理论可接受任意频率时钟, 实际最低要保证位选过程不被人眼分辨
		clk								  : IN std_logic;
		-- 存储单管输出, 共6个, 每个UNIT_COUNT段
		sg1, sg2, sg3, sg4, sg5, sg6 : IN std_logic_vector((UNIT_COUNT - 1) DOWNTO 0);
		-- 选择后的单管输出
		sg									  : OUT std_logic_vector((UNIT_COUNT - 1) DOWNTO 0);
		-- ym_38(6数码管)输入源
		sel								  : OUT std_logic_vector(2 DOWNTO 0)
	);
END ENTITY jmp;

ARCHITECTURE arch OF jmp IS
	-- 代表MAX_COUNT个数码管
	SIGNAL cnt : integer RANGE 0 TO (MAX_COUNT - 1) := 0;
BEGIN
	PROCESS(clk)
	BEGIN
		IF (clk'event and (clk = '1')) THEN
			cnt <= cnt + 1;
			-- 当前为最后一个(第MAX_COUNT位)数码管?
			IF (cnt >= (MAX_COUNT - 1)) THEN
				-- 置为第一个
				cnt <= 0;
			END IF;
		END IF;
	END PROCESS;

	-- 根据main.vhd, 从左到右数码管为sg6, sg5, sg4, sg3, sg2, sg1
	WITH cnt SELECT
		-- 显示对应数码管
		sel <= "101" WHEN 0,
			    "100" WHEN 1,
			    "011" WHEN 2,
			    "010" WHEN 3,
			    "001" WHEN 4,
				 "000" WHEN 5;
	WITH cnt SELECT
		-- 选择输出与之上数码管对应的数
		sg <= sg1 WHEN 0,
			   sg2 WHEN 1,
			   sg3 WHEN 2,
			   sg4 WHEN 3,
			   sg5 WHEN 4,
			   sg6 WHEN 5;
END ARCHITECTURE arch;