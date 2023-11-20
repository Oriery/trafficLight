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
  PROCESS (I, S)
  BEGIN
    CASE S IS
      WHEN "00" =>
        A <= I;
        B <= '0';
        C <= '0';
        D <= '0';
      WHEN "01" =>
        A <= '0';
        B <= I;
        C <= '0';
        D <= '0';
      WHEN "10" =>
        A <= '0';
        B <= '0';
        C <= I;
        D <= '0';
      WHEN "11" =>
        A <= '0';
        B <= '0';
        C <= '0';
        D <= I;
      WHEN OTHERS =>
        A <= '0';
        B <= '0';
        C <= '0';
        D <= '0';
    END CASE;
  END PROCESS;
END Behavioral;