LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
--****2015210078 张楷****
--LED控制模块
--根据外部传入的状态
--决定显示模式
--********2017.11********
ENTITY LEDCtrl IS
	PORT(PWMclock:IN STD_LOGIC;                         --PWM计数频率(应为其输出波形频率的256倍，计划256KHz以上)
        Switchclock:IN STD_LOGIC;                       --行扫描频率(应大于刷新率的8倍，计划160Hz以上)
        Breathclock:IN STD_LOGIC;                       --呼吸步进频率(严格为170Hz)
        Rollclock:IN STD_LOGIC;                         --循环时钟
		LEDEnable:IN STD_LOGIC;                         --点阵使能
        State:IN INTEGER  RANGE 0 TO 3;                 --0:左 1:右 2:停 3:正常
        reset:IN STD_LOGIC;                             --复位
        Lineout: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);      --输出行控信号
        Columnout: OUT STD_LOGIC_VECTOR(15 DOWNTO 0));  --输出列控信号
END LEDCtrl;

ARCHITECTURE LEDCtrler OF LEDCtrl IS
    COMPONENT LEDRefresh
        GENERIC (IMGNUM : INTEGER := 6);
        PORT(Rollclock:IN STD_LOGIC;                        --循环时钟
            PWMclock:IN STD_LOGIC;                          --PWM计数频率(应为其输出波形频率的256倍，计划256KHz以上)
            Switchclock:IN STD_LOGIC;                       --行扫描频率(应大于刷新率的8倍，计划160Hz以上)
            LEDEnable:IN STD_LOGIC;                         --点阵使能
            reset:IN STD_LOGIC;                             --复位
            luma:IN INTEGER  RANGE 0 TO 255;                --亮度(直接输入给PWM作为占空比)
            DataSel: IN INTEGER  RANGE 0 TO IMGNUM-1;       --图像选择
            Lineout: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);      --输出行控信号
            Columnout: OUT STD_LOGIC_VECTOR(15 DOWNTO 0));  --输出列控信号
    END COMPONENT;
    SIGNAL RsvCount:STD_LOGIC;                  --计数增减标记(RsvCount=1减计数,RsvCount=0增计数)
    SIGNAL BreathCount:INTEGER RANGE 0 TO 511;  --呼吸计数器(亮度值)
	SIGNAL IMGSel:INTEGER RANGE 0 TO 5;         --图案选择
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
            IF(State = 3)THEN   --正常状态
                --呼吸灯
                IF(Breathclock'event AND Breathclock='0')THEN   --亮度变化(呼吸灯) 0->255->0
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
                --图片切换
                IF(RsvCount'event AND RsvCount='0')THEN
                    IF(IMGSel>2 AND IMGSel<5)THEN
                        IMGSel<=IMGSel+1;
                    ELSE
                        IMGSel<=3;
                    END IF;
                END IF;
            ELSIF(State = 2)THEN    --停止状态
                BreathCount <= 255; --亮度
                RsvCount <= '0';    --重置计数标记
                IMGSel<=2;          --设置图片
            ELSIF(State = 1)THEN    --右转状态
                BreathCount <= 255;
                RsvCount <= '0';
                IMGSel<=1;
            ELSIF(State = 0)THEN    --左转状态
                BreathCount <= 255;
                RsvCount <= '0';
                IMGSel<=0;
            END IF;
		END IF;
	END PROCESS;
END LEDCtrler;