-- 主文件
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

USE work.global_config.MAX;
USE work.jmp_config.MAX_COUNT;
USE work.counter_config.UNIT_COUNT;

ENTITY main IS
	PORT(
		-- s1 置零
		-- s2 0.1s 1s 3s
		s1, s2				  : IN std_logic;
		clk					  : IN std_logic;
		-- ym_38源
		sel					  : OUT std_logic_vector(2 DOWNTO 0);
		-- 单管输出
		seg					  : OUT std_logic_vector(0 TO (UNIT_COUNT - 1));
		-- led
		d					  : OUT std_logic_vector(3 DOWNTO 0)
	);
END ENTITY main;

ARCHITECTURE arch OF main IS
	COMPONENT led IS
		PORT(
			s : IN std_logic;
			b : OUT std_logic_vector
		);
	END COMPONENT led;
	COMPONENT jmp IS
		PORT(
			clk								  : IN std_logic;
			sg1, sg2, sg3, sg4, sg5, sg6 	  : IN std_logic_vector;
			sg								  : OUT std_logic_vector;
			sel								  : OUT std_logic_vector
		);
	END COMPONENT jmp;
	COMPONENT counter IS
		PORT(
			rst, clk	: IN std_logic;
			co			: OUT std_logic;
			q			: OUT std_logic_vector(0 TO (UNIT_COUNT - 1))
		);
	END COMPONENT counter;
	-- 存储进位
	SIGNAL carry										: std_logic_vector(0 TO (MAX_COUNT - 1));
	-- 存储单管输出
	SIGNAL sgo1, sgo2, sgo3, sgo4, sgo5, sgo6 : std_logic_vector((UNIT_COUNT - 1) DOWNTO 0);
	-- 分频系数变量
	SIGNAL modulus										: integer RANGE 1 TO 500000000 := 25000000;
	-- 存储分频系数变量
	SIGNAL md											: integer RANGE 1 TO 500000000 := 25000000;
	-- 单管时钟
	SIGNAL sp_clk										: std_logic;
	-- 扫描时钟
	SIGNAL j_clk										: std_logic;
	-- 全局计数完成?
	SIGNAL flag											: std_logic;
BEGIN
	-- s2
	prmd2:PROCESS(s2, md)
	VARIABLE st : integer RANGE 0 TO 2 := 1;
	BEGIN
		IF (s2'event and (s2 = '1')) THEN
			CASE st IS
				WHEN 0 => md <= 2500000;
				WHEN 1 => md <= 25000000;
				WHEN 2 => md <= 75000000;
			END CASE;
			IF (st < 2) THEN
				st := st + 1;
			ELSE
				st := 0;
			END IF;
		END IF;
		modulus <= md;
	END PROCESS prmd2;
	-- 单管分频
	prclk:PROCESS(clk)
		VARIABLE cnt : integer RANGE 0 TO 500000000 := 0;
	BEGIN
		IF (clk'event and (clk = '1')) THEN
			cnt := cnt + 1;
			IF (cnt >= modulus) THEN
				cnt := 0;
				sp_clk <= not sp_clk;
			END IF;
		END IF;
	END PROCESS prclk;
	sclk:PROCESS(clk)
		VARIABLE cnt : integer RANGE 0 TO 500000000 := 0;
	BEGIN
		IF (clk'event and (clk = '1')) THEN
			cnt := cnt + 1;
			-- 扫描分频
			IF (cnt >= 20000) THEN
				j_clk <= not j_clk;
				cnt := 0;
			END IF;
		END IF;
	END PROCESS sclk;
	aclk:PROCESS(sp_clk, s1)
		-- 全局计数
		VARIABLE gcnt : integer RANGE 0 TO MAX := 0;
	BEGIN
		IF (sp_clk'event and (sp_clk = '1')) THEN
			IF ((s1 and not flag) = '1') THEN
				gcnt := gcnt + 1;
			ELSE
				gcnt := 0;
			END IF;
			IF (gcnt >= MAX) THEN
				flag <= '1';
				gcnt := 0;
			ELSE
				flag <= '0';
			END IF;
		END IF;
	END PROCESS aclk;
	ct1  : counter PORT MAP(s1 and not flag, sp_clk, carry(0), sgo1);
	ct2  : counter PORT MAP(s1 and not flag, carry(0), carry(1), sgo2);
	ct3  : counter PORT MAP(s1 and not flag, carry(1), carry(2), sgo3);
	ct4  : counter PORT MAP(s1 and not flag, carry(2), carry(3), sgo4);
	ct5  : counter PORT MAP(s1 and not flag, carry(3), carry(4), sgo5);
	ct6  : counter PORT MAP(s1 and not flag, carry(4), carry(5), sgo6);
	jump : jmp PORT MAP(j_clk, sgo1, sgo2, sgo3, sgo4, sgo5, sgo6, seg, sel);
	l	 : led PORT MAP(not flag, d);
END ARCHITECTURE arch;