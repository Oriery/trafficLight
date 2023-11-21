LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY TwoStepDFF IS
  PORT (
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    D : IN STD_LOGIC;
    Q : OUT STD_LOGIC);
END TwoStepDFF;

ARCHITECTURE Behavioral OF TwoStepDFF IS
  SIGNAL intermediate : STD_LOGIC;
  SIGNAL notClk : STD_LOGIC;
BEGIN
  -- First D flip-flop
  DFF1 : ENTITY work.D_FlipFlop
    PORT MAP(
      clk => clk,
      reset => reset,
      D => D,
      Q => intermediate
    );

  -- Second D flip-flop
  DFF2 : ENTITY work.D_FlipFlop
    PORT MAP(
      clk => notClk,
      reset => reset,
      D => intermediate,
      Q => Q
    );

  notClk <= NOT clk;
END Behavioral;