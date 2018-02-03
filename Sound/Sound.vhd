LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
--****2015210078 �ſ�****
--������Ԫ
--********2017.11********
ENTITY Sound IS
    GENERIC (SoundNum:INTEGER := 2;n:INTEGER:= 255);--����,���ַ�Χ
	PORT(Soundclock:IN STD_LOGIC;                   --�ϸ�Ϊ8Hz
        CTCclock:IN STD_LOGIC;                      --�ϸ�Ϊ100KHz��10us
		reset:IN STD_LOGIC;                         --��λ
        enable:IN STD_LOGIC;                        --ʹ��
        SoundSel:IN INTEGER RANGE 0 TO SoundNum-1;  --ѡ��
		Soundout:OUT STD_LOGIC);                    --���
END Sound;

ARCHITECTURE SoundGenerater OF Sound IS
	COMPONENT CTC
        GENERIC (n : INTEGER := 255);           --������Χ������������5.12ms
        PORT(CTCclock:IN STD_LOGIC;             --�ϸ�Ϊ100KHz��10us
            enable:IN STD_LOGIC;                --����
            halfperoid:IN INTEGER  RANGE 0 TO n;--���������(0.01ms��halfperoidperoid��),����Ϊ0.01ms��2*halfperoidperoid��
            CTCoutput:OUT STD_LOGIC);           --���
	END COMPONENT;
    SIGNAL SoundFrep:INTEGER  RANGE 0 TO n;     --����Ƶ��           
    SIGNAL count:INTEGER  RANGE 0 TO 63;        --���Ž��ȼ���
    SIGNAL CTCEnable:STD_LOGIC;                 --CTCģ��ʹ��
    TYPE MUSIC IS ARRAY (SoundNum-1 DOWNTO 0,63 DOWNTO 0) OF INTEGER  RANGE 0 TO 31;--0-21
    --0��ʾ������
    constant Data:MUSIC:=
    ((0,6,6,7,7,8,8,9 , 10,10,11,11,12,12,13,13,
      14,14,15,15,16,16,15,15 , 14,14,13,13,12,12,11,11,
      0,6,6,7,7,8,8,9 , 10,10,11,11,12,12,13,13,
      14,14,15,15,16,16,15,15 , 14,14,13,13,12,12,11,11),
    --8,8,9,9
    ( 0,10,9,8,8,9,11,10 , 11,12,12,11,10,10,10,12,
      9,8,9,10,11,10,9,8 , 9,10,11,12,12,11,10,10,
      0,6,6,7,7,8,8,9 , 10,10,11,11,12,12,13,13,
      9,9,10,10,10,9,8,8 , 9,10,11,12,12,11,10,10)
    );
    TYPE TuneTable IS ARRAY (21 DOWNTO 0) OF INTEGER  RANGE 0 TO 255;
    constant Tune:TuneTable:=
    (21,20,19,18,17,43,48,
    51,57,64,72,76,85,96,
    101,114,5,4,3,2,1,
    0);
BEGIN
    CTCWaveGen : CTC PORT MAP (CTCclock=>CTCclock,enable=>CTCEnable,halfperoid=>SoundFrep,CTCoutput=>Soundout);
	PROCESS(Soundclock,reset,count,enable)
	BEGIN
		IF(enable='0' OR reset='1')THEN
			count<=0;
            SoundFrep <= 0;
            CTCEnable <= enable;
		ELSIF(Soundclock'event AND Soundclock='0')THEN
			IF(Data(SoundSel,count)=31)THEN
				count<=0;
                SoundFrep <= 0;
                CTCEnable <= '0';
			ELSE
                IF(Data(SoundSel,count)=0)THEN
                    SoundFrep <= Tune(Data(SoundSel,count));
                    CTCEnable <= '0';
                ELSE
                    SoundFrep <= Tune(Data(SoundSel,count));
                    CTCEnable <= enable;
                END IF;
				count<=count+1;
			END IF;
		END IF;
	END PROCESS;
END SoundGenerater;