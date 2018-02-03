LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
--****2015210078 �ſ�****
--���г�β��������
--********2017.11********
ENTITY Core IS
	PORT(rawclock:IN STD_LOGIC;                         --ԭʼʱ���ź�
        userreset:IN STD_LOGIC;                         --��λ�ź�
        TurnRight:IN STD_LOGIC;                         --��ת�ź�
        TurnLeft:IN STD_LOGIC;                          --��ת�ź�
        Stop:IN STD_LOGIC;                              --ͣ���ź�
        Night:IN STD_LOGIC;                             --�����ź�,�й�ߵ�ƽ���޹�͵�ƽ
        LEDSel:OUT STD_LOGIC_VECTOR(7 DOWNTO 0);        --�����ѡ���ź�
		LEDData:OUT STD_LOGIC_VECTOR(7 DOWNTO 0);       --�������ʾ�ź�
        LEDLineSel: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);   --LED��ѡ
        LEDColumn: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);   --LED������
        Echo:IN STD_LOGIC;                              --��ƽ����
        Tri:OUT STD_LOGIC;                              --����
        SoundOut:OUT STD_LOGIC);                        --��Ƶ����ź�
END Core;

ARCHITECTURE main OF Core IS
	COMPONENT TimeCount
        PORT(Timeclock:IN STD_LOGIC;                        --�ϸ�Ϊ1Hz
            Freshclock:IN STD_LOGIC;                        --����500Hz
            Triclock:IN STD_LOGIC;                          --����Ϊ20Hz
            Countclock:IN STD_LOGIC;                        --����2941��Ƶ
            UREnable:IN STD_LOGIC;
            reset:IN STD_LOGIC;                             --����
            Echo:IN STD_LOGIC;                              --��ƽ����
            Tri:OUT STD_LOGIC;                              --����
            LEDSel:OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            LEDData:OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
	END COMPONENT;
    COMPONENT ClockDiv
        GENERIC (div:INTEGER);          --��Ƶ�� ֻ����˫����Ƶ��
        PORT(clock:IN STD_LOGIC;        --����ʱ��
            reset:IN STD_LOGIC;         --��λ
            output:OUT STD_LOGIC);      --���
    END COMPONENT;
    COMPONENT Sound
        GENERIC (SoundNum:INTEGER := 2;n:INTEGER:= 255);--����,���ַ�Χ
        PORT(Soundclock:IN STD_LOGIC;                   --�ϸ�Ϊ8Hz
            CTCclock:IN STD_LOGIC;                      --�ϸ�Ϊ100KHz��10us
            reset:IN STD_LOGIC;                         --��λ
            enable:IN STD_LOGIC;                        --ʹ��
            SoundSel:IN INTEGER RANGE 0 TO SoundNum-1;  --ѡ��
            Soundout:OUT STD_LOGIC);                    --���
    END COMPONENT;
    COMPONENT LEDCtrl
        PORT(PWMclock:IN STD_LOGIC;                         --PWM����Ƶ��(ӦΪ���������Ƶ�ʵ�256�����ƻ�256KHz����)
            Switchclock:IN STD_LOGIC;                       --��ɨ��Ƶ��(Ӧ����ˢ���ʵ�8�����ƻ�160Hz����)
            Breathclock:IN STD_LOGIC;                       --��������Ƶ��(�ϸ�Ϊ170Hz)
            Rollclock:IN STD_LOGIC;                         --ѭ��ʱ��
            LEDEnable:IN STD_LOGIC;                         --����ʹ��
            State:IN INTEGER  RANGE 0 TO 3;                 --0:�� 1:�� 2:ͣ 3:����
            reset:IN STD_LOGIC;                             --��λ
            Lineout: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);      --����п��ź�
            Columnout: OUT STD_LOGIC_VECTOR(15 DOWNTO 0));  --����п��ź�
    END COMPONENT;
    COMPONENT EdgeToLevel
        PORT(reset:IN STD_LOGIC;    --����
            Input:IN STD_LOGIC;     --�����ź�(��������Ч)                     
            Output:OUT STD_LOGIC);  --����ź�(��ƽ��Ч) 
    END COMPONENT;
    COMPONENT EliminationBuffeting IS
    GENERIC (CountRange : INTEGER);--32
	PORT(reset:IN STD_LOGIC;        --����
        clock:IN STD_LOGIC;         --�ϸ�Ϊ50M
		Input:IN STD_LOGIC;    
        Output:INOUT STD_LOGIC);
    END COMPONENT;
    --<\��Ƶ��ʱ��
    SIGNAL C1MHz:STD_LOGIC;
    SIGNAL C100KHz:STD_LOGIC;
    SIGNAL C17KHz:STD_LOGIC; -- 17001.0200612Hz
    SIGNAL C1KHz:STD_LOGIC;
    SIGNAL C500Hz:STD_LOGIC;
    SIGNAL C500HzEB:STD_LOGIC;
    SIGNAL C170Hz:STD_LOGIC;--169.999796Hz
    SIGNAL C4Hz:STD_LOGIC;
    SIGNAL C8Hz:STD_LOGIC;
    SIGNAL C1Hz:STD_LOGIC;
    --��Ƶ��ʱ��/>
    SIGNAL SoundEnable:STD_LOGIC;--����ʹ��
    SIGNAL SoundSel:INTEGER RANGE 0 TO 1;--��Чѡ��
    SIGNAL SoundCount:INTEGER RANGE 0 TO 7;--��������ʱ
    SIGNAL StateEnable:STD_LOGIC;--״̬�л�ʹ��
    SIGNAL LEDCount:INTEGER RANGE 0 TO 10;--LEDת��5S����ʱ
    SIGNAL State:INTEGER RANGE 0 TO 3;--LEDʹ��
    --��������
    SIGNAL RightEB:STD_LOGIC;--��ת��ƽ
    SIGNAL LeftEB:STD_LOGIC;--��ת��ƽ
    SIGNAL StopEB:STD_LOGIC;--��ת��ƽ
    --������ת��ƽ
    SIGNAL RightLevel:STD_LOGIC;--��ת��ƽ
    SIGNAL LeftLevel:STD_LOGIC;--��ת��ƽ
    SIGNAL StopLevel:STD_LOGIC;--��ת��ƽ
    --��λ
    SIGNAL userresetEB:STD_LOGIC;--��λ��������
    SIGNAL OnOff:STD_LOGIC;--���ص�ƽ
    SIGNAL reset:STD_LOGIC;--�ۺϸ�λ��ƽ
    --���������ʹ��
    SIGNAL UREnable:STD_LOGIC;
BEGIN
    --ClockCenter
    C1M : ClockDiv GENERIC MAP (div=>50)
    PORT MAP (clock=>rawclock,reset=>reset,output=>C1MHz);
    C100K : ClockDiv GENERIC MAP (div=>10)
    PORT MAP (clock=>C1MHz,reset=>reset,output=>C100KHz);
    C17K : ClockDiv GENERIC MAP (div=>2941)  -- 17001.0200612Hz
    PORT MAP (clock=>rawclock,reset=>reset,output=>C17KHz);
    C1K : ClockDiv GENERIC MAP (div=>50000)
    PORT MAP (clock=>rawclock,reset=>reset,output=>C1KHz);
    C500 : ClockDiv GENERIC MAP (div=>2)
    PORT MAP (clock=>C1KHz,reset=>reset,output=>C500Hz);
    C170 : ClockDiv GENERIC MAP (div=>294118)--169.999796Hz
    PORT MAP (clock=>rawclock,reset=>reset,output=>C170Hz);
    C4 : ClockDiv GENERIC MAP (div=>125)
    PORT MAP (clock=>C500Hz,reset=>reset,output=>C4Hz);
    C8 : ClockDiv GENERIC MAP (div=>125)
    PORT MAP (clock=>C1KHz,reset=>reset,output=>C8Hz);
    C1 : ClockDiv GENERIC MAP (div=>8) 
    PORT MAP (clock=>C8Hz,reset=>reset,output=>C1Hz);
    --TimeCount
	LEDTimeCount : TimeCount PORT MAP (Timeclock=>C1Hz,Freshclock=>C500Hz,Triclock=>C1Hz,
    Countclock=>C17KHz,UREnable=>UREnable,reset=>reset,Echo=>Echo,Tri=>Tri,LEDSel=>LEDSel,LEDData=>LEDData);
    --Sound
    StartSound : Sound PORT MAP (Soundclock=>C4Hz,CTCclock=>C100KHz,
    reset=>reset,enable=>SoundEnable,SoundSel=>SoundSel,Soundout=>SoundOut);
    --LEDPoint
    LEDP : LEDCtrl PORT MAP (PWMclock=>C1MHz,Switchclock=>C500Hz,Breathclock=>C170Hz,Rollclock=>C8Hz,
    LEDEnable=>Night,State=>State,reset=>reset,Lineout=>LEDLineSel,Columnout=>LEDColumn);
    --EliminationBuffeting
    ToRightEB : EliminationBuffeting GENERIC MAP (CountRange=>128) 
    PORT MAP (reset=>reset,clock=>C500Hz, Input=>TurnRight, Output=>RightEB);
    ToLeftEB : EliminationBuffeting GENERIC MAP (CountRange=>128) 
    PORT MAP (reset=>reset,clock=>C500Hz, Input=>TurnLeft, Output=>LeftEB);
    ToStopEB : EliminationBuffeting GENERIC MAP (CountRange=>128) 
    PORT MAP (reset=>reset,clock=>C500Hz, Input=>Stop, Output=>StopEB);
    ToResetEB : EliminationBuffeting GENERIC MAP (CountRange=>1500000) 
    PORT MAP (reset=>'0',clock=>rawclock, Input=>userreset, Output=>userresetEB);--�����������resetӰ��
    --EdgeToLevel
    ToRightLevel : EdgeToLevel PORT MAP (reset=>reset, Input=>RightEB, Output=>RightLevel);
    ToLeftLevel : EdgeToLevel PORT MAP (reset=>reset, Input=>LeftEB, Output=>LeftLevel);
    ToStopLevel : EdgeToLevel PORT MAP (reset=>reset, Input=>StopEB, Output=>StopLevel);
    --��λ����
    reset <= (NOT OnOff);-- OR (NOT Night)
	PROCESS(userresetEB,userreset)
	BEGIN
		IF(userresetEB'event AND userresetEB='1')THEN
			OnOff <= NOT OnOff;
		END IF;
	END PROCESS;
    --����5S����
	PROCESS(C1Hz,reset,SoundCount,SoundEnable)
	BEGIN
		IF(reset='1')THEN
            SoundEnable<='1';
            SoundSel<=0;
            StateEnable <= '0';
            SoundCount<=0;
            UREnable<='0';
		ELSE
			IF(C1Hz'event AND C1Hz='0')THEN
				IF(SoundCount=5)THEN
					SoundEnable<='0';
                    StateEnable <= '1';
				ELSIF(SoundCount=4)THEN
                    UREnable<='1';
					StateEnable <= '1';
					SoundCount<=SoundCount+1;
				ELSE
                    StateEnable <= '0';
					SoundCount<=SoundCount+1;
					SoundEnable<='1';
					SoundSel<=0;
				END IF;
			END IF;
		END IF;
	END PROCESS;
    --ˢ��State
	PROCESS(State,StateEnable,C1Hz,RightLevel,LeftLevel,StopLevel,reset)
	BEGIN
        IF(reset='1' OR StateEnable='0')THEN
            State <= 3;
            LEDCount <= 0;
        ELSE
            IF(C1Hz'event AND C1Hz='0')THEN
                IF(State=2 AND LEDCount=4)THEN
                    State <= 3;
                    LEDCount <= 0;
                ELSIF(State=1 AND LEDCount=9)THEN
                    State <= 3;
                    LEDCount <= 0;
                ELSIF(State=0 AND LEDCount=9)THEN
                    State <= 3;
                    LEDCount <= 0;  
                ELSE
					LEDCount <= LEDCount+1;
				END IF;
			END IF;
			IF(StopLevel='1')THEN
				State <= 2;
				LEDCount <= 0;
			ELSIF(RightLevel='1')THEN
				State <= 1;
				LEDCount <= 0;
			ELSIF(LeftLevel='1')THEN
				State <= 0;
				LEDCount <= 0;
			END IF;
        END IF;
	END PROCESS;
END main;