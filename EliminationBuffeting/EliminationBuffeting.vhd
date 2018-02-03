LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
--****2015210078 �ſ�****
--����
--ֻֻ�е���ƽ�仯�������㹻����ʱ��֮��
--����Ϊ�ñ仯����Ч��,���򱣳ֵ�ǰ״̬
--********2017.11********
ENTITY EliminationBuffeting IS
    GENERIC (CountRange : INTEGER := 64);   --��Ч����ֵ,ֻ�дﵽ�ü�����������Ϊ�仯����Ч��
	PORT(reset:IN STD_LOGIC;                --��λ
        clock:IN STD_LOGIC;                 --����ʱ��
		Input:IN STD_LOGIC;                 --�����ƽ
        Output:INOUT STD_LOGIC);            --�����ƽ
END EliminationBuffeting;

ARCHITECTURE EB OF EliminationBuffeting IS
    SIGNAL Timeing:INTEGER  RANGE 0 TO CountRange-1;    --�ڲ�������
BEGIN
	PROCESS(Input,clock,reset)
	BEGIN
		IF(reset='1')THEN
			Output <= '0';
		ELSE
            IF(clock'event AND clock='1')THEN
                IF(Input = '1' AND Output = '0')THEN
                    IF(Timeing=CountRange-1)THEN
                        Output <= '1';
                    ELSE
                        Timeing<=Timeing+1;
                    END IF;
                ELSIF(Input = '0' AND Output = '1')THEN
                    IF(Timeing=CountRange-1)THEN
                        Output <= '0';
                    ELSE
                        Timeing<=Timeing+1;
                    END IF;
                ELSE
                    Timeing<=0;
                    Output<=Output;
                END IF;
            END IF;
        END IF;
	END PROCESS;
END EB;