LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
--****2015210078 张楷****
--LED数码管显示
--********2017.11********
ENTITY LedShowe IS
	PORT(input:IN STD_LOGIC_VECTOR(4 DOWNTO 0); --显示内容输入
	output:OUT STD_LOGIC_VECTOR(7 DOWNTO 0));   --显示信号输出
END LedShowe;

ARCHITECTURE LedShower OF LedShowe IS
BEGIN
	PROCESS(input)
	BEGIN
		CASE input IS
			WHEN "00000" => output <="01111110";--0
			WHEN "00001" => output <="00110000";--1
			WHEN "00010" => output <="01101101";--2
			WHEN "00011" => output <="01111001";--3
			WHEN "00100" => output <="00110011";--4
			WHEN "00101" => output <="01011011";--5
			WHEN "00110" => output <="01011111";--6
			WHEN "00111" => output <="01110000";--7
			WHEN "01000" => output <="01111111";--8
			WHEN "01001" => output <="01111011";--9
			WHEN "01010" => output <="00000001";--10 -
			WHEN "10000" => output <="11111110";--0.
			WHEN "10001" => output <="10110000";--1.
			WHEN "10010" => output <="11101101";--2.
			WHEN "10011" => output <="11111001";--3.
			WHEN "10100" => output <="10110011";--4.
			WHEN "10101" => output <="11011011";--5.
			WHEN "10110" => output <="11011111";--6.
			WHEN "10111" => output <="11110000";--7.
			WHEN "11000" => output <="11111111";--8.
			WHEN "11001" => output <="11111011";--9.
			WHEN "11010" => output <="10000001";--10 -.
			WHEN OTHERS => output <="00000000";--OFF
		END CASE;
	END PROCESS;
END LedShower;
