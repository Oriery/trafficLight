LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY tb_D_FlipFlop IS
END tb_D_FlipFlop;

ARCHITECTURE Behavioral OF tb_D_FlipFlop IS

  COMPONENT D_FlipFlop IS
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      D : IN STD_LOGIC;
      Q : OUT STD_LOGIC);
  END COMPONENT;

  SIGNAL clk : STD_LOGIC := '0';
  SIGNAL reset : STD_LOGIC := '0';
  SIGNAL D : STD_LOGIC := '0';
  SIGNAL Q : STD_LOGIC;

  CONSTANT period : TIME := 2 ns;
  CONSTANT clk_period : TIME := 9 ns;

BEGIN

  uut : D_FlipFlop PORT MAP(
    clk => clk,
    reset => reset,
    D => D,
    Q => Q);

  stim_Clk : PROCESS
  BEGIN
    WAIT FOR clk_period;
    Clk <= NOT Clk;
  END PROCESS;

  stim_D : PROCESS
  BEGIN
    WAIT FOR period;
    D <= NOT D;
  END PROCESS;

  stim_Reset : PROCESS
  BEGIN
    WAIT FOR clk_period * 10;
    reset <= NOT reset;
  END PROCESS;

END Behavioral;