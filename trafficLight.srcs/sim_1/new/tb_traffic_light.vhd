LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
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
      ClkDividedOut : OUT STD_LOGIC);
  END COMPONENT;

  SIGNAL IsOn : STD_LOGIC := '1';
  SIGNAL Clk : STD_LOGIC := '0';
  SIGNAL Red : STD_LOGIC;
  SIGNAL Green : STD_LOGIC;
  SIGNAL RedOnSecondLed : STD_LOGIC;
  SIGNAL GreenOnSecondLed : STD_LOGIC;
  SIGNAL IsOnOut : STD_LOGIC;
  SIGNAL ClkDividedOut : STD_LOGIC;

  CONSTANT period : TIME := 2ns;
  signal error : std_logic;
BEGIN
  uut: trafficLight PORT MAP (
    IsOn => IsOn,
    Clk => Clk,
    Red => Red,
    Green => Green,
    RedOnSecondLed => RedOnSecondLed,
    GreenOnSecondLed => GreenOnSecondLed,
    IsOnOut => IsOnOut,
    ClkDividedOut => ClkDividedOut);

  stim_Clk: process
  begin
    wait for period;
    Clk <= not Clk;
  end process;

  stim_IsOn: process
  begin
    wait for period * 100;
    IsOn <= not IsOn;
  end process;

  error <= RedOnSecondLed xor GreenOnSecondLed; -- yellow should be on only when both red and green are on

END Behavioral;