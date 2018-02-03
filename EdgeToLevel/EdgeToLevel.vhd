LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
--****2015210078 �ſ�****
--����ƽת�̵�ƽ
--�仯��ת�̵�ƽ
--����ʱ�Ӽ��ɹ���,�����˼Ĵ�������ʱ
--********2017.11********
ENTITY EdgeToLevel IS
	PORT(reset:IN STD_LOGIC;        --��λ
		Input:IN STD_LOGIC;         --����
        Output:INOUT STD_LOGIC);    --���
END EdgeToLevel;

ARCHITECTURE ETL OF EdgeToLevel IS
    SIGNAL Si:STD_LOGIC;    --����Ĵ���
    SIGNAL St:STD_LOGIC;    --�м�Ĵ���
    SIGNAL So:STD_LOGIC;    --����Ĵ���
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