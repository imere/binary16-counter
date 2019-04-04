-- 全局 配置
LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- 定义包global_config
PACKAGE global_config IS
	-- 全局最大计数
	CONSTANT MAX : integer RANGE 0 TO 65535 := 20;
END PACKAGE global_config;