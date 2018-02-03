LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
--****2015210078 �ſ�****
--��Ƶ����������
--����������2.55*2=5.10ms
--
--********2017.11********
ENTITY CTC IS
	GENERIC (n : INTEGER := 255);           --����������2.55*2=5.10ms
	PORT(CTCclock:IN STD_LOGIC;             --�ϸ�Ϊ100KHz��10us
		enable:IN STD_LOGIC;                --����
		halfperoid:IN INTEGER  RANGE 0 TO n;--���������(0.01ms��halfperoidperoid��),����Ϊ0.01ms��2*halfperoidperoid��
		CTCoutput:INOUT STD_LOGIC);         --���
        --CTCoutput:OUT STD_LOGIC);           --���
END CTC;

ARCHITECTURE CTCGenerater OF CTC IS
	SIGNAL count:INTEGER RANGE 0 TO n*2;    --������
    SIGNAL outtmp:STD_LOGIC;                --����Ĵ���
BEGIN
	PROCESS(CTCclock,count,outtmp,halfperoid,enable)
	BEGIN
		IF(enable='0')THEN
			count<=0;
			--outtmp<='0';
            CTCoutput<='0';
		ELSIF(CTCclock'event AND CTCclock='0')THEN
			IF(count=halfperoid)THEN
				count<=0;
				--outtmp<=NOT outtmp;
                CTCoutput<=NOT CTCoutput;
			ELSE
				count<=count+1;
			END IF;
		END IF;
	END PROCESS;
    --CTCoutput <= outtmp;
END CTCGenerater;