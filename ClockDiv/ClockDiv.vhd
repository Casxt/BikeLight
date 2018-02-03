LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
--****2015210078 �ſ�****
--��Ƶ��
--��Ƶ��ֱ���ò�������
--��ԼӲ����Դ
--********2017.11********
ENTITY ClockDiv IS
	--ֻ����˫����Ƶ��
	GENERIC (div : INTEGER := 6);   --��Ƶ��
	PORT(clock:IN STD_LOGIC;        --ʱ������
		reset:IN STD_LOGIC;         --��λ
		output:INOUT STD_LOGIC);    --���ʱ��
END ClockDiv;

ARCHITECTURE ClockDivider OF ClockDiv IS
	SIGNAL count:INTEGER RANGE 0 TO div/2-1;    --������,����div��Ƶ,ֻ��Ҫ������div/2-1
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