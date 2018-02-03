LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
--****2015210078 张楷****
--电平长度测量
--输出信号十进制计数
--最大值9999
--********2017.11********
ENTITY MeasureLevel IS
	GENERIC (CountRange : INTEGER := 1024);                 --可测10M
	PORT(Countclock:IN STD_LOGIC;                           --计数时钟2941分频,每计数1cm
		reset:IN STD_LOGIC;                                 --复位
        Level:IN STD_LOGIC;                                 --待测电平信号
		n0:OUT STD_LOGIC_VECTOR(3 DOWNTO 0);                --最低位
        n1:OUT STD_LOGIC_VECTOR(3 DOWNTO 0);                --次低位
        n2:OUT STD_LOGIC_VECTOR(3 DOWNTO 0);                --次高位
        n3:OUT STD_LOGIC_VECTOR(3 DOWNTO 0));               --最高位
END MeasureLevel;
ARCHITECTURE Measurer OF MeasureLevel IS
    COMPONENT EdgeToLevel
        PORT(reset:IN STD_LOGIC;    --重置
            Input:IN STD_LOGIC;     --输入信号(上升沿有效) 
            Output:OUT STD_LOGIC);  --输出信号(电平有效) 
    END COMPONENT;
    COMPONENT DNum
        PORT(clock,reset:IN STD_LOGIC;                  --输入时钟,复位
            output: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);   --输出
            c1: OUT STD_LOGIC);                         --进位信号
	END COMPONENT;
    SIGNAL UpEdge:STD_LOGIC;        --上升沿,开始计数
    SIGNAL DNumreset:STD_LOGIC;     --上升沿,计数重置
    SIGNAL DNumclock:STD_LOGIC;     --计数时钟
    SIGNAL c0:STD_LOGIC;            --最低位计数器进位信号
    SIGNAL c1:STD_LOGIC;            --次低位计数器进位信号
    SIGNAL c2:STD_LOGIC;            --次高位计数器进位信号
BEGIN
    ToUpLevel : EdgeToLevel PORT MAP (reset=>reset, Input=>Level, Output=>UpEdge);
    DNumreset<=reset OR UpEdge;
    DNumclock<=Level AND Countclock;
    D0 : DNum PORT MAP (clock=>DNumclock,reset=>DNumreset,output=>n0,c1=>c0);
    D1 : DNum PORT MAP (clock=>c0,reset=>DNumreset,output=>n1,c1=>c1);
    D2 : DNum PORT MAP (clock=>c1,reset=>DNumreset,output=>n2,c1=>c2);
    D3 : DNum PORT MAP (clock=>c2,reset=>DNumreset,output=>n3,c1=>OPEN);
END Measurer;