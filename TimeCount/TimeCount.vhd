LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.NUMERIC_STD.ALL;
--****2015210078 张楷****
--计时单元
--测距单元
--********2017.11********
ENTITY TimeCount IS
    GENERIC (CountRange : INTEGER := 1024);
	PORT(Timeclock:IN STD_LOGIC;                        --严格为1Hz
        Freshclock:IN STD_LOGIC;                        --建议500Hz
        Triclock:IN STD_LOGIC;                          --建议为20Hz
        Countclock:IN STD_LOGIC;                        --建议2941分频
		UREnable:IN STD_LOGIC;                          --测距使能
        reset:IN STD_LOGIC;                             --重置
        Echo:IN STD_LOGIC;                              --电平读入
        Tri:OUT STD_LOGIC;                              --触发
		LEDSel:OUT STD_LOGIC_VECTOR(7 DOWNTO 0);        --数码管选择
        LEDData:OUT STD_LOGIC_VECTOR(7 DOWNTO 0));      --数码管显示信号
END TimeCount;

ARCHITECTURE TimeCounter OF TimeCount IS
	COMPONENT DNum
        PORT(clock,reset:IN STD_LOGIC;                  --输入时钟,复位
            output: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);   --输出
            c1: OUT STD_LOGIC);                         --进位信号
	END COMPONENT;
	COMPONENT LedShowe
        PORT(input:IN STD_LOGIC_VECTOR(4 DOWNTO 0);     --显示内容输入
            output:OUT STD_LOGIC_VECTOR(7 DOWNTO 0));   --显示信号输出
	END COMPONENT;
    COMPONENT UltrasonicRanging
        GENERIC (CountRange : INTEGER := CountRange);
        PORT(Triclock:IN STD_LOGIC;                         --建议为20Hz
            Countclock:IN STD_LOGIC;                        --建议2941分频
            UREnable:IN STD_LOGIC;
            reset:IN STD_LOGIC; 
            Echo:IN STD_LOGIC;                               --电平读入
            Tri:OUT STD_LOGIC;                               --触发
            n0:OUT STD_LOGIC_VECTOR(3 DOWNTO 0);    --输出信号
            n1:OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            n2:OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            n3:OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
    END COMPONENT;
	SIGNAL count:INTEGER RANGE 0 TO 7;              --数码管刷新计数器
    --SIGNAL Timecount:INTEGER RANGE 0 TO 127;        
    SIGNAL c0:STD_LOGIC;                            --计时器进位信号
    SIGNAL n0:STD_LOGIC_VECTOR(3 DOWNTO 0);         --时间计数器低位
    SIGNAL n1:STD_LOGIC_VECTOR(3 DOWNTO 0);         --时间计数器高位
    SIGNAL distance0:STD_LOGIC_VECTOR(3 DOWNTO 0);  --距离计数器最低位
    SIGNAL distance1:STD_LOGIC_VECTOR(3 DOWNTO 0);  --距离计数器次低位
    SIGNAL distance2:STD_LOGIC_VECTOR(3 DOWNTO 0);  --距离计数器次高位
    SIGNAL distance3:STD_LOGIC_VECTOR(3 DOWNTO 0);  --距离计数器最高位
    SIGNAL LEDNum:STD_LOGIC_VECTOR(4 DOWNTO 0);     --数字
    --SIGNAL Distance:INTEGER RANGE 0 TO CountRange-1;
BEGIN
    D0 : DNum PORT MAP (clock=>Timeclock,reset=>reset,output=>n0,c1=>c0);
    D1 : DNum PORT MAP (clock=>c0,reset=>reset,output=>n1,c1=>OPEN);
    LED : LedShowe PORT MAP (input=>LEDNum,output=>LEDData);
    UR : UltrasonicRanging PORT MAP (Triclock=>Triclock,Countclock=>Countclock,UREnable=>UREnable,reset=>reset,
    Echo=>Echo,Tri=>Tri,n0=>distance0,n1=>distance1,n2=>distance2,n3=>distance3);
	PROCESS(Freshclock,Timeclock,LEDNum,count,reset,UREnable,n0,n1,distance0,distance1,distance2,distance3)
	BEGIN
        --选择要显示的数码管
		IF(reset='1')THEN
			count<=0;
            LEDSel<= "11111111";
		ELSE
            IF(Freshclock'event AND Freshclock='0')THEN
                count <= count+1;
            END IF;
            -- IF(Timeclock'event AND Timeclock='0')THEN
                -- IF(Timecount=99)THEN
                    -- Timecount <= 0;
                -- ELSE
                    -- Timecount <= Timecount+1;
                -- END IF;
            -- END IF;
            LEDSel<= TO_STDLOGICVECTOR(TO_BITVECTOR("11111110") ROL count);
        END IF;
        
        --选择显示内容
		IF(UREnable='1')THEN
            IF(distance3="0000")THEN
				CASE count IS 
				WHEN 0 => LEDNum <="00000" OR n0;           --四位转五位
				WHEN 1 => LEDNum <="00000" OR n1;
				WHEN 2 => LEDNum <="11111";                 --不输出
				WHEN 3 => LEDNum <="11111";
				WHEN 4 => LEDNum <="00000" OR distance0;
				WHEN 5 => LEDNum <="00000" OR distance1;
				WHEN 6 => LEDNum <="10000" OR distance2;    --加小数点
				WHEN 7 => LEDNum <="00000" OR distance3;
				END CASE;
			ELSE
				CASE count IS 
				WHEN 0 => LEDNum <="00000" OR n0;
				WHEN 1 => LEDNum <="00000" OR n1;
				WHEN 2 => LEDNum <="11111";
				WHEN 3 => LEDNum <="11111";
				WHEN 4 => LEDNum <="01010";
				WHEN 5 => LEDNum <="01010";
				WHEN 6 => LEDNum <="01010";
				WHEN 7 => LEDNum <="01010";
				END CASE;
            END IF;
        ELSE
            CASE count IS 
            WHEN 0 => LEDNum <="00000" OR n0;
            WHEN 1 => LEDNum <="00000" OR n1;
            WHEN 2 => LEDNum <="11111";
            WHEN 3 => LEDNum <="11111";
            WHEN 4 => LEDNum <="11111";
            WHEN 5 => LEDNum <="11111";
            WHEN 6 => LEDNum <="11111";
            WHEN 7 => LEDNum <="11111";
            END CASE;
		END IF;

	END PROCESS;
END TimeCounter;