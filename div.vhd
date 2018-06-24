LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

USE work.jmp_config.MAX_COUNT;
USE work.counter_config.UNIT_COUNT;

ENTITY div IS
	PORT(
		i : IN std_logic;
		o : OUT std_logic
	);
END ENTITY div;

ARCHITECTURE act OF div IS
BEGIN
	-- 分频
	prclk:PROCESS(i)
		-- 时钟计数
		VARIABLE cnt : integer RANGE 0 TO 50000000 := 0;
	BEGIN
		IF (i'event and (i = '1')) THEN
			cnt := cnt + 1;
			IF (cnt > 5000000) THEN
				cnt := 0;
				o <= '1';
			ELSE
				o <= '0';
			END IF;
		END IF;
	END PROCESS prclk;
END ARCHITECTURE act;