LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
--****2015210078 张楷****
--消抖
--只只有当电平变化并保持足够长的时间之后
--才认为该变化是有效的,否则保持当前状态
--********2017.11********
ENTITY EliminationBuffeting IS
    GENERIC (CountRange : INTEGER := 64);   --有效计数值,只有达到该计数次数才认为变化是有效的
	PORT(reset:IN STD_LOGIC;                --复位
        clock:IN STD_LOGIC;                 --输入时钟
		Input:IN STD_LOGIC;                 --输入电平
        Output:INOUT STD_LOGIC);            --输出电平
END EliminationBuffeting;

ARCHITECTURE EB OF EliminationBuffeting IS
    SIGNAL Timeing:INTEGER  RANGE 0 TO CountRange-1;    --内部计数器
BEGIN
	PROCESS(Input,clock,reset)
	BEGIN
		IF(reset='1')THEN
			Output <= '0';
		ELSE
            IF(clock'event AND clock='1')THEN
                IF(Input = '1' AND Output = '0')THEN
                    IF(Timeing=CountRange-1)THEN
                        Output <= '1';
                    ELSE
                        Timeing<=Timeing+1;
                    END IF;
                ELSIF(Input = '0' AND Output = '1')THEN
                    IF(Timeing=CountRange-1)THEN
                        Output <= '0';
                    ELSE
                        Timeing<=Timeing+1;
                    END IF;
                ELSE
                    Timeing<=0;
                    Output<=Output;
                END IF;
            END IF;
        END IF;
	END PROCESS;
END EB;