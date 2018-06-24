-- MAX_COUNT个数码管跳变/扫描
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

USE work.counter_config.UNIT_COUNT;
USE work.jmp_config.all;

ENTITY jmp IS
	PORT(
		clk								  : IN std_logic;
		-- 存储单管输出
		sg1, sg2, sg3, sg4, sg5, sg6 : IN std_logic_vector((UNIT_COUNT - 1) DOWNTO 0);
		-- 单管输出
		sg									  : OUT std_logic_vector((UNIT_COUNT - 1) DOWNTO 0);
		-- ym_38输入源
		sel								  : OUT std_logic_vector(2 DOWNTO 0)
	);
END ENTITY jmp;

ARCHITECTURE arch OF jmp IS
	SIGNAL cnt : integer RANGE 0 TO (MAX_COUNT - 1) := 0;
BEGIN
	PROCESS(clk)
	BEGIN
		IF (clk'event and (clk = '1')) THEN
			cnt <= cnt + 1;
			IF (cnt >= (MAX_COUNT - 1)) THEN
				cnt <= 0;
			END IF;
		END IF;
	END PROCESS;
	WITH cnt SELECT
		sel <= "101" WHEN 0,
			    "100" WHEN 1,
			    "011" WHEN 2,
			    "010" WHEN 3,
			    "001" WHEN 4,
				 "000" WHEN 5;
	WITH cnt SELECT
		sg <= sg1 WHEN 0,
			   sg2 WHEN 1,
			   sg3 WHEN 2,
			   sg4 WHEN 3,
			   sg5 WHEN 4,
			   sg6 WHEN 5;
END ARCHITECTURE arch;