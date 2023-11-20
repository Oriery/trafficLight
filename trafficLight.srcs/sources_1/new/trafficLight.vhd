----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.11.2023 17:56:02
-- Design Name: 
-- Module Name: trafficLight - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY trafficLight IS
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
    ColorSelectorOut : OUT STD_LOGIC_VECTOR(1 DOWNTO 0));
END trafficLight;

ARCHITECTURE Behavioral OF trafficLight IS

  COMPONENT clock_divider
    GENERIC (
      divider : INTEGER
    );
    PORT (
      clk_in : IN STD_LOGIC;
      clk_out : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT increment_by_one
    GENERIC (
      vector_length : INTEGER
    );
    PORT (
      input_vector : IN STD_LOGIC_VECTOR(vector_length - 1 DOWNTO 0);
      output_vector : OUT STD_LOGIC_VECTOR(vector_length - 1 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT mux_2
    PORT (
      A : IN STD_LOGIC;
      B : IN STD_LOGIC;
      S : IN STD_LOGIC;
      Z : OUT STD_LOGIC);
  END COMPONENT;

  COMPONENT mux_4_2
    PORT (
      A : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      B : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      S : IN STD_LOGIC;
      Z : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
  END COMPONENT;

  SIGNAL clkDivided : STD_LOGIC;
  SIGNAL yellow : STD_LOGIC;
  SIGNAL state : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00"; -- 00 = green, 01 = yellow, 10 = red, 11 = redYellow
  SIGNAL nextState : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL colorSelector : STD_LOGIC_VECTOR(1 DOWNTO 0); -- like state but can be forced to yellow '01' when traffic light is off

BEGIN
  -- slow down clk to be 1Hz
  slowDownClk : clock_divider
  GENERIC MAP(
    divider => 2 -- TODO: change to 100000000 when using real system clock
  )
  PORT MAP(
    clk_in => Clk,
    clk_out => clkDivided
  );

  -- calc next state
  setNextState : increment_by_one
  GENERIC MAP(
    vector_length => 2
  )
  PORT MAP(
    input_vector => state,
    output_vector => nextState
  );

  -- set colorSelector
  setColorSelector : mux_4_2
  PORT MAP(
    A => "01",
    B => state,
    S => IsOn,
    Z => colorSelector
  );

  Red <= '1' WHEN IsOn = '1' ELSE
    '0';

  RedOnSecondLed <= yellow;
  GreenOnSecondLed <= yellow;

  -- TEMP:

  process(clkDivided)
  begin
    if rising_edge(clkDivided) then
      state <= nextState;
    end if;
  end process;

  -- for debugging:
  IsOnOut <= IsOn;
  ClkDividedOut <= clkDivided;
  ColorSelectorOut <= colorSelector;
END Behavioral;