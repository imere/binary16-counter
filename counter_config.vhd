-- counter 配置
LIBRARY ieee;
USE ieee.std_logic_1164.all;

PACKAGE counter_config IS
	-- 单管利用单元数
	CONSTANT UNIT_COUNT		  : integer RANGE 0 TO 8 := 7;
	-- 单管最大计数量/进制
	CONSTANT MAX_SINGLE_COUNT : integer RANGE 0 TO 10 := 10;
	-- 处理数据 适应对应输出
	FUNCTION outFix(SIGNAL to_be_process: std_logic_vector)
		RETURN std_logic_vector;
END PACKAGE counter_config;

PACKAGE BODY counter_config IS
	FUNCTION outFix(SIGNAL to_be_process: std_logic_vector)
		RETURN std_logic_vector IS
		VARIABLE rt: std_logic_vector((UNIT_COUNT - 1) DOWNTO 0);
		BEGIN
			CASE to_be_process IS
				-- rt 对应数码管单元 低电平有效
				WHEN "0000" => rt := "0000001";
				WHEN "0001" => rt := "1001111";
				WHEN "0010" => rt := "0010010";
				WHEN "0011" => rt := "0000110";
				WHEN "0100" => rt := "1001100";
				WHEN "0101" => rt := "0100100";
				WHEN "0110" => rt := "0100000";
				WHEN "0111" => rt := "0001111";
				WHEN "1000" => rt := "0000000";
				WHEN "1001" => rt := "0000100";
				WHEN OTHERS =>	rt := "1111110";
			END CASE;
		RETURN rt;
	END FUNCTION outFix;
END PACKAGE BODY counter_config;