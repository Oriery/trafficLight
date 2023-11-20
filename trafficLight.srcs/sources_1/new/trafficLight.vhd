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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity trafficLight is
    Port ( IsOn : in STD_LOGIC;
           Clk : in STD_LOGIC;
           Red : out STD_LOGIC;
           Green : out STD_LOGIC;
           Blue : out STD_LOGIC;
           -- Dubugs
           IsOnOut : out STD_LOGIC
        );
end trafficLight;

architecture Behavioral of trafficLight is

begin
Red <= '1' when IsOn = '1' else '0';
IsOnOut <= IsOn;
end Behavioral;
