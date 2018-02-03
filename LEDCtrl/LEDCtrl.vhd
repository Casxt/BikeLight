LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
--****2015210078 �ſ�****
--LED����ģ��
--�����ⲿ�����״̬
--������ʾģʽ
--********2017.11********
ENTITY LEDCtrl IS
	PORT(PWMclock:IN STD_LOGIC;                         --PWM����Ƶ��(ӦΪ���������Ƶ�ʵ�256�����ƻ�256KHz����)
        Switchclock:IN STD_LOGIC;                       --��ɨ��Ƶ��(Ӧ����ˢ���ʵ�8�����ƻ�160Hz����)
        Breathclock:IN STD_LOGIC;                       --��������Ƶ��(�ϸ�Ϊ170Hz)
        Rollclock:IN STD_LOGIC;                         --ѭ��ʱ��
		LEDEnable:IN STD_LOGIC;                         --����ʹ��
        State:IN INTEGER  RANGE 0 TO 3;                 --0:�� 1:�� 2:ͣ 3:����
        reset:IN STD_LOGIC;                             --��λ
        Lineout: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);      --����п��ź�
        Columnout: OUT STD_LOGIC_VECTOR(15 DOWNTO 0));  --����п��ź�
END LEDCtrl;

ARCHITECTURE LEDCtrler OF LEDCtrl IS
    COMPONENT LEDRefresh
        GENERIC (IMGNUM : INTEGER := 6);
        PORT(Rollclock:IN STD_LOGIC;                        --ѭ��ʱ��
            PWMclock:IN STD_LOGIC;                          --PWM����Ƶ��(ӦΪ���������Ƶ�ʵ�256�����ƻ�256KHz����)
            Switchclock:IN STD_LOGIC;                       --��ɨ��Ƶ��(Ӧ����ˢ���ʵ�8�����ƻ�160Hz����)
            LEDEnable:IN STD_LOGIC;                         --����ʹ��
            reset:IN STD_LOGIC;                             --��λ
            luma:IN INTEGER  RANGE 0 TO 255;                --����(ֱ�������PWM��Ϊռ�ձ�)
            DataSel: IN INTEGER  RANGE 0 TO IMGNUM-1;       --ͼ��ѡ��
            Lineout: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);      --����п��ź�
            Columnout: OUT STD_LOGIC_VECTOR(15 DOWNTO 0));  --����п��ź�
    END COMPONENT;
    SIGNAL RsvCount:STD_LOGIC;                  --�����������(RsvCount=1������,RsvCount=0������)
    SIGNAL BreathCount:INTEGER RANGE 0 TO 511;  --����������(����ֵ)
	SIGNAL IMGSel:INTEGER RANGE 0 TO 5;         --ͼ��ѡ��
BEGIN
    LEDPoint : LEDRefresh PORT MAP (Rollclock=>Rollclock,PWMclock=>PWMclock,Switchclock=>Switchclock,LEDEnable=>LEDEnable,
    reset=>reset,luma=>BreathCount,DataSel=>IMGSel,Lineout=>Lineout,Columnout=>Columnout);
	PROCESS(Breathclock,State,reset,IMGSel,BreathCount,RsvCount,LEDEnable)
	BEGIN
		IF(reset='1' OR LEDEnable='0')THEN
            BreathCount <= 0;
            RsvCount <= '0';
            IMGSel <= 3;
		ELSE
            IF(State = 3)THEN   --����״̬
                --������
                IF(Breathclock'event AND Breathclock='0')THEN   --���ȱ仯(������) 0->255->0
                    IF(BreathCount=255)THEN
                        RsvCount <= NOT RsvCount;
                        BreathCount <= BreathCount-1;
                    ELSIF(BreathCount=0)THEN
                        RsvCount <= NOT RsvCount;
                        BreathCount <= BreathCount+1;
                    ELSE
                        IF(RsvCount='0')THEN
                            BreathCount <= BreathCount+1;
                        ELSE
                            BreathCount <= BreathCount-1;
                        END IF;
                    END IF;
                END IF;
                --ͼƬ�л�
                IF(RsvCount'event AND RsvCount='0')THEN
                    IF(IMGSel>2 AND IMGSel<5)THEN
                        IMGSel<=IMGSel+1;
                    ELSE
                        IMGSel<=3;
                    END IF;
                END IF;
            ELSIF(State = 2)THEN    --ֹͣ״̬
                BreathCount <= 255; --����
                RsvCount <= '0';    --���ü������
                IMGSel<=2;          --����ͼƬ
            ELSIF(State = 1)THEN    --��ת״̬
                BreathCount <= 255;
                RsvCount <= '0';
                IMGSel<=1;
            ELSIF(State = 0)THEN    --��ת״̬
                BreathCount <= 255;
                RsvCount <= '0';
                IMGSel<=0;
            END IF;
		END IF;
	END PROCESS;
END LEDCtrler;