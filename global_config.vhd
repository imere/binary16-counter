-- 全局 配置
LIBRARY ieee;
USE ieee.std_logic_1164.all;

PACKAGE global_config IS
	-- 最大数
	CONSTANT MAX : integer RANGE 0 TO 65535 := 65535;
END PACKAGE global_config;