LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
--****2015210078 张楷****
--动态占空比方波发生器
--255级分辨率
--********2017.11********
ENTITY PWM IS
	GENERIC (n : INTEGER := 255);
	PORT(PWMclock:IN STD_LOGIC;         --PWM计数频率(应为其输出波形频率的256倍)
		reset:IN STD_LOGIC;             --重置
		div:IN INTEGER  RANGE 0 TO n;   --占空比0-255
		output:OUT STD_LOGIC);          --输出
END PWM;

ARCHITECTURE PWMGenerater OF PWM IS
	SIGNAL count:INTEGER RANGE 0 TO n;
BEGIN
	PROCESS(PWMclock,reset)
	BEGIN
		IF(reset='1')THEN
			count<=0;
			output<='0';
		ELSIF(PWMclock'event AND PWMclock='1')THEN
            IF(count<=div)THEN
				output<='1';
			ELSE
				output<='0';
			END IF;
			count<=count+1;
		END IF;
	END PROCESS;
END PWMGenerater;