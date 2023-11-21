LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY D_FlipFlop IS
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    D : IN STD_LOGIC;
    Q : OUT STD_LOGIC);
END D_FlipFlop;

ARCHITECTURE Behavioral OF D_FlipFlop IS
  SIGNAL tempQ : STD_LOGIC := '0';
BEGIN
  PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      tempQ <= '0';
    ELSIF rising_edge(clk) THEN
      tempQ <= D;
    END IF;
  END PROCESS;
  Q <= tempQ;
END Behavioral;