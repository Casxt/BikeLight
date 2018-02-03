LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
--****2015210078 张楷****
--分频器
--分频比直接用参数定义
--节约硬件资源
--********2017.11********
ENTITY ClockDiv IS
	--只允许双数分频比
	GENERIC (div : INTEGER := 6);   --分频比
	PORT(clock:IN STD_LOGIC;        --时钟输入
		reset:IN STD_LOGIC;         --复位
		output:INOUT STD_LOGIC);    --输出时钟
END ClockDiv;

ARCHITECTURE ClockDivider OF ClockDiv IS
	SIGNAL count:INTEGER RANGE 0 TO div/2-1;    --计数器,对于div分频,只需要计数至div/2-1
BEGIN
	PROCESS(clock,reset)
	BEGIN
		IF(reset='1')THEN
			count<=0;
		ELSIF(clock'event AND clock='0')THEN
			IF(count=div/2-1)THEN
				count<=0;
                output <= NOT output;
			ELSE
				count<=count+1;
			END IF;
		END IF;
	END PROCESS;
END ClockDivider;