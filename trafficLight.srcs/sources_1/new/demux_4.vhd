LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY demux_4 IS
  PORT (
    I : IN STD_LOGIC;
    S : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    A : OUT STD_LOGIC;
    B : OUT STD_LOGIC;
    C : OUT STD_LOGIC;
    D : OUT STD_LOGIC
  );
END demux_4;

ARCHITECTURE Behavioral OF demux_4 IS
BEGIN
  A <= I WHEN S = "00" ELSE '0';
  B <= I WHEN S = "01" ELSE '0';
  C <= I WHEN S = "10" ELSE '0';
  D <= I WHEN S = "11" ELSE '0';
END Behavioral;