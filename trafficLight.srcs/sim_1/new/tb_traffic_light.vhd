LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY tb_traffic_light IS
END tb_traffic_light;

ARCHITECTURE Behavioral OF tb_traffic_light IS

  COMPONENT trafficLight IS
    PORT (
      IsOn : IN STD_LOGIC;
      Clk : IN STD_LOGIC;
      Red : OUT STD_LOGIC;
      Green : OUT STD_LOGIC;
      RedOnSecondLed : OUT STD_LOGIC; -- for yellow
      GreenOnSecondLed : OUT STD_LOGIC; -- for yellow
      -- Dubugs
      IsOnOut : OUT STD_LOGIC;
      ClkDividedOut : OUT STD_LOGIC;
      ColorSelectorOut : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      timeTillNextStateOut : OUT UNSIGNED(7 DOWNTO 0)
    );
  END COMPONENT;

  SIGNAL IsOn : STD_LOGIC := '1';
  SIGNAL Clk : STD_LOGIC := '0';
  SIGNAL Red : STD_LOGIC;
  SIGNAL Green : STD_LOGIC;
  SIGNAL RedOnSecondLed : STD_LOGIC;
  SIGNAL GreenOnSecondLed : STD_LOGIC;
  SIGNAL IsOnOut : STD_LOGIC;
  SIGNAL ClkDividedOut : STD_LOGIC;
  SIGNAL ColorSelectorOut : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL TimeTillNextStateOut : UNSIGNED(7 DOWNTO 0);

  CONSTANT period : TIME := 1ns;
  SIGNAL error : STD_LOGIC;
BEGIN
  uut : trafficLight PORT MAP(
    IsOn => IsOn,
    Clk => Clk,
    Red => Red,
    Green => Green,
    RedOnSecondLed => RedOnSecondLed,
    GreenOnSecondLed => GreenOnSecondLed,
    IsOnOut => IsOnOut,
    ClkDividedOut => ClkDividedOut,
    ColorSelectorOut => ColorSelectorOut,
    TimeTillNextStateOut => TimeTillNextStateOut);

  stim_Clk : PROCESS
  BEGIN
    WAIT FOR period;
    Clk <= NOT Clk;
  END PROCESS;

  stim_IsOn : PROCESS
  BEGIN
    WAIT FOR period * 400;
    IsOn <= NOT IsOn;
  END PROCESS;

  error <= RedOnSecondLed XOR GreenOnSecondLed; -- yellow should be on only when both red and green are on

END Behavioral;