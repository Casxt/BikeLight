LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.NUMERIC_STD.ALL;
--****2015210078 张楷****
--测距模块
--周期性触发测距模块工作
--并返回测得数据
--********2017.11********
ENTITY UltrasonicRanging IS
    GENERIC (CountRange : INTEGER := 1024);     --计数器范围
	PORT(Triclock:IN STD_LOGIC;                 --建议为20Hz
        Countclock:IN STD_LOGIC;                --建议2941分频
        UREnable:IN STD_LOGIC;                  --测距使能
        reset:IN STD_LOGIC;                     --复位
        Echo:IN STD_LOGIC;                      --触发
		Tri:INOUT STD_LOGIC;                    --触发
        n0:OUT STD_LOGIC_VECTOR(3 DOWNTO 0);    --最低位
        n1:OUT STD_LOGIC_VECTOR(3 DOWNTO 0);    --次低位
        n2:OUT STD_LOGIC_VECTOR(3 DOWNTO 0);    --次高位
        n3:OUT STD_LOGIC_VECTOR(3 DOWNTO 0));   --最高位
END UltrasonicRanging;

ARCHITECTURE UR OF UltrasonicRanging IS
	COMPONENT MeasureLevel
        GENERIC (CountRange : INTEGER := 1024);     --可测10M
        PORT(Countclock:IN STD_LOGIC;               --计数时钟2941分频,每计数1cm
            reset:IN STD_LOGIC;                     --复位
            Level:IN STD_LOGIC;                     --待测电平信号
            n0:OUT STD_LOGIC_VECTOR(3 DOWNTO 0);    --最低位
            n1:OUT STD_LOGIC_VECTOR(3 DOWNTO 0);    --次低位
            n2:OUT STD_LOGIC_VECTOR(3 DOWNTO 0);    --次高位
            n3:OUT STD_LOGIC_VECTOR(3 DOWNTO 0));   --最高位
	END COMPONENT;
    COMPONENT EdgeToLevel
        PORT(reset:IN STD_LOGIC;        --复位
            Input:IN STD_LOGIC;         --输入
            Output:INOUT STD_LOGIC);    --输出
    END COMPONENT;
    --SIGNAL t : STD_LOGIC;
BEGIN
    ML : MeasureLevel PORT MAP (Countclock=>Countclock,reset=>reset,Level=>Echo,n0=>n0,n1=>n1,n2=>n2,n3=>n3);
	PROCESS(UREnable,Triclock,reset)
	BEGIN
		IF(reset='1' OR UREnable='0')THEN
			Tri<='0';
		ELSE
			Tri<=Triclock;
		END IF;
	END PROCESS;
    
END UR;