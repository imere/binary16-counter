-- 单数码管输出
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

USE work.counter_config.all;

ENTITY counter IS
	PORT(
		rst, clk : IN std_logic;
		-- 进位
		co			: OUT std_logic;
		q			: OUT std_logic_vector(0 TO (UNIT_COUNT - 1))
	);
END ENTITY counter;

ARCHITECTURE arch OF counter IS
	SIGNAL cnt : std_logic_vector(3 DOWNTO 0);
BEGIN
	count:PROCESS(rst, clk)
		BEGIN
		IF (rst = '0') THEN
			co <= '0';
			cnt <= (OTHERS => '0');
		ELSIF (clk'event and (clk = '1')) THEN
			cnt <= cnt + 1;
			IF (cnt >= MAX_SINGLE_COUNT - 1) THEN
				co <= '1';
				cnt <= (OTHERS => '0');
			ELSE
				co <= '0';
			END IF;
		END IF;
	END PROCESS count;
	q <= outFix(cnt);
END ARCHITECTURE arch;