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
    ClkDividedOut : OUT STD_LOGIC);
END trafficLight;

ARCHITECTURE Behavioral OF trafficLight IS

  COMPONENT clock_divider
    GENERIC (
      divider : NATURAL
    );
    PORT (
      clk_in : IN STD_LOGIC;
      clk_out : OUT STD_LOGIC
    );
  END COMPONENT;

  SIGNAL clkDivided : STD_LOGIC;
  SIGNAL yellow : STD_LOGIC;

BEGIN
  clk_div_inst : clock_divider
  GENERIC MAP(
    divider => 2 -- TODO: change to 100000000 when using real system clock
  )
  PORT MAP(
    clk_in => Clk,
    clk_out => clkDivided
  );

  Red <= '1' WHEN IsOn = '1' ELSE
    '0';

  RedOnSecondLed <= yellow;
  GreenOnSecondLed <= yellow;

  -- for debugging:
  IsOnOut <= IsOn;
  ClkDividedOut <= clkDivided;
END Behavioral;