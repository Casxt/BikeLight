LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
--****2015210078 张楷****
--变频方波发生器
--最大输出周期2.55*2=5.10ms
--
--********2017.11********
ENTITY CTC IS
	GENERIC (n : INTEGER := 255);           --最大输出周期2.55*2=5.10ms
	PORT(CTCclock:IN STD_LOGIC;             --严格为100KHz，10us
		enable:IN STD_LOGIC;                --重置
		halfperoid:IN INTEGER  RANGE 0 TO n;--输出半周期(0.01ms的halfperoidperoid倍),周期为0.01ms的2*halfperoidperoid倍
		CTCoutput:INOUT STD_LOGIC);         --输出
        --CTCoutput:OUT STD_LOGIC);           --输出
END CTC;

ARCHITECTURE CTCGenerater OF CTC IS
	SIGNAL count:INTEGER RANGE 0 TO n*2;    --计数器
    SIGNAL outtmp:STD_LOGIC;                --输出寄存器
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