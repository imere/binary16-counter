-- jmp 配置
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.numeric_std.all;

PACKAGE jmp_config IS
	-- 最大使用数码管数
	CONSTANT MAX_COUNT : integer RANGE 1 TO 6 := 6;
END PACKAGE jmp_config;