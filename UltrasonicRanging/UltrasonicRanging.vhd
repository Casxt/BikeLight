LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.NUMERIC_STD.ALL;
--****2015210078 �ſ�****
--���ģ��
--�����Դ������ģ�鹤��
--�����ز������
--********2017.11********
ENTITY UltrasonicRanging IS
    GENERIC (CountRange : INTEGER := 1024);     --��������Χ
	PORT(Triclock:IN STD_LOGIC;                 --����Ϊ20Hz
        Countclock:IN STD_LOGIC;                --����2941��Ƶ
        UREnable:IN STD_LOGIC;                  --���ʹ��
        reset:IN STD_LOGIC;                     --��λ
        Echo:IN STD_LOGIC;                      --����
		Tri:INOUT STD_LOGIC;                    --����
        n0:OUT STD_LOGIC_VECTOR(3 DOWNTO 0);    --���λ
        n1:OUT STD_LOGIC_VECTOR(3 DOWNTO 0);    --�ε�λ
        n2:OUT STD_LOGIC_VECTOR(3 DOWNTO 0);    --�θ�λ
        n3:OUT STD_LOGIC_VECTOR(3 DOWNTO 0));   --���λ
END UltrasonicRanging;

ARCHITECTURE UR OF UltrasonicRanging IS
	COMPONENT MeasureLevel
        GENERIC (CountRange : INTEGER := 1024);     --�ɲ�10M
        PORT(Countclock:IN STD_LOGIC;               --����ʱ��2941��Ƶ,ÿ����1cm
            reset:IN STD_LOGIC;                     --��λ
            Level:IN STD_LOGIC;                     --�����ƽ�ź�
            n0:OUT STD_LOGIC_VECTOR(3 DOWNTO 0);    --���λ
            n1:OUT STD_LOGIC_VECTOR(3 DOWNTO 0);    --�ε�λ
            n2:OUT STD_LOGIC_VECTOR(3 DOWNTO 0);    --�θ�λ
            n3:OUT STD_LOGIC_VECTOR(3 DOWNTO 0));   --���λ
	END COMPONENT;
    COMPONENT EdgeToLevel
        PORT(reset:IN STD_LOGIC;        --��λ
            Input:IN STD_LOGIC;         --����
            Output:INOUT STD_LOGIC);    --���
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