-- LED
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY led IS
	PORT(
		-- 控制端
		s : IN std_logic;
		-- 输出, 共4个led
		b : OUT std_logic_vector(3 DOWNTO 0)
	);
END ENTITY led;

ARCHITECTURE bhv OF led IS
BEGIN
	WITH s SELECT
		-- led低电有效
		b <= "0000" WHEN '0',
			  "1111" WHEN '1',
			  NULL WHEN OTHERS;
END ARCHITECTURE bhv;