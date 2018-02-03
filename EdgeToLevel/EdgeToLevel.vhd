LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
--****2015210078 张楷****
--长电平转短电平
--变化沿转短电平
--无需时钟即可工作,利用了寄存器的延时
--********2017.11********
ENTITY EdgeToLevel IS
	PORT(reset:IN STD_LOGIC;        --复位
		Input:IN STD_LOGIC;         --输入
        Output:INOUT STD_LOGIC);    --输出
END EdgeToLevel;

ARCHITECTURE ETL OF EdgeToLevel IS
    SIGNAL Si:STD_LOGIC;    --输入寄存器
    SIGNAL St:STD_LOGIC;    --中间寄存器
    SIGNAL So:STD_LOGIC;    --输出寄存器
BEGIN
	PROCESS(Input,St,So,Si,reset)
	BEGIN
		IF(reset='1')THEN
			Si <= '0';
		ELSE
            IF(Input'event AND Input='1')THEN
                Si <= NOT Si;
			END IF;
			St <= Si;
			So <= St;
			Output <= So XOR Si;
        END IF;
	END PROCESS;
END ETL;