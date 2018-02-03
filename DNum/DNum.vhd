LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
--****2015210078 张楷****
--十进制计数器
--带进位
--
--********2017.11********
ENTITY DNum IS
	PORT(clock,reset:IN STD_LOGIC;                  --输入时钟,复位
		output: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);   --输出
		c1: OUT STD_LOGIC);                         --进位信号
END DNum;

ARCHITECTURE CountDNum OF DNum IS
	SIGNAL count:INTEGER  RANGE 0 TO 15;            --内部计数器
BEGIN
	PROCESS(count,clock,reset)
	BEGIN
		IF(reset='1')THEN
			count<=0;
			c1<='1';
		ELSIF(clock'event AND clock='0')THEN
			IF count=9 THEN
                count<=0;
				c1<='0';
			ELSE
				count<=count+1;
				c1<='1';
			END IF;
		END IF;
        output<=CONV_STD_LOGIC_VECTOR(count,4);
	END PROCESS;
END CountDNum;