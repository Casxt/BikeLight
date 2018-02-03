LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
--****2015210078 �ſ�****
--��ƽ���Ȳ���
--����ź�ʮ���Ƽ���
--���ֵ9999
--********2017.11********
ENTITY MeasureLevel IS
	GENERIC (CountRange : INTEGER := 1024);                 --�ɲ�10M
	PORT(Countclock:IN STD_LOGIC;                           --����ʱ��2941��Ƶ,ÿ����1cm
		reset:IN STD_LOGIC;                                 --��λ
        Level:IN STD_LOGIC;                                 --�����ƽ�ź�
		n0:OUT STD_LOGIC_VECTOR(3 DOWNTO 0);                --���λ
        n1:OUT STD_LOGIC_VECTOR(3 DOWNTO 0);                --�ε�λ
        n2:OUT STD_LOGIC_VECTOR(3 DOWNTO 0);                --�θ�λ
        n3:OUT STD_LOGIC_VECTOR(3 DOWNTO 0));               --���λ
END MeasureLevel;
ARCHITECTURE Measurer OF MeasureLevel IS
    COMPONENT EdgeToLevel
        PORT(reset:IN STD_LOGIC;    --����
            Input:IN STD_LOGIC;     --�����ź�(��������Ч) 
            Output:OUT STD_LOGIC);  --����ź�(��ƽ��Ч) 
    END COMPONENT;
    COMPONENT DNum
        PORT(clock,reset:IN STD_LOGIC;                  --����ʱ��,��λ
            output: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);   --���
            c1: OUT STD_LOGIC);                         --��λ�ź�
	END COMPONENT;
    SIGNAL UpEdge:STD_LOGIC;        --������,��ʼ����
    SIGNAL DNumreset:STD_LOGIC;     --������,��������
    SIGNAL DNumclock:STD_LOGIC;     --����ʱ��
    SIGNAL c0:STD_LOGIC;            --���λ��������λ�ź�
    SIGNAL c1:STD_LOGIC;            --�ε�λ��������λ�ź�
    SIGNAL c2:STD_LOGIC;            --�θ�λ��������λ�ź�
BEGIN
    ToUpLevel : EdgeToLevel PORT MAP (reset=>reset, Input=>Level, Output=>UpEdge);
    DNumreset<=reset OR UpEdge;
    DNumclock<=Level AND Countclock;
    D0 : DNum PORT MAP (clock=>DNumclock,reset=>DNumreset,output=>n0,c1=>c0);
    D1 : DNum PORT MAP (clock=>c0,reset=>DNumreset,output=>n1,c1=>c1);
    D2 : DNum PORT MAP (clock=>c1,reset=>DNumreset,output=>n2,c1=>c2);
    D3 : DNum PORT MAP (clock=>c2,reset=>DNumreset,output=>n3,c1=>OPEN);
END Measurer;