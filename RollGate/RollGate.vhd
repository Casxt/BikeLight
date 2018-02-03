LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
--****2015210078 张楷****
--8位移位输出器
--255级分辨率
--********2017.11********
ENTITY RollGate IS
	PORT(Rollclock:IN STD_LOGIC;                    --移位时钟
        reset:IN STD_LOGIC;                         --复位
        Enable:IN STD_LOGIC;                        --移位使能
        Direction:IN STD_LOGIC;                     --1左0右
        input:IN STD_LOGIC_VECTOR(7 DOWNTO 0);      --待移位信号
        output:OUT STD_LOGIC_VECTOR(7 DOWNTO 0));   --输出
END RollGate;

ARCHITECTURE Roller OF RollGate IS
SIGNAL RollCount:INTEGER RANGE 0 TO 7;              --移位计数
BEGIN
	PROCESS(Rollclock,reset,Enable,input,Direction,RollCount)
	BEGIN
        IF(reset='1' OR Enable='0')THEN
            RollCount<=0;
        ELSE
            IF(Rollclock'event AND Rollclock='0')THEN
                RollCount <= RollCount+1;
            END IF;
        END IF;
        FOR i IN 0 TO 7 LOOP
            IF (Direction='1')THEN
            output(i) <= input(i+RollCount);
            ELSE
            output(i) <= input(i-RollCount);
            END IF;
        END LOOP;
	END PROCESS;
END Roller;
