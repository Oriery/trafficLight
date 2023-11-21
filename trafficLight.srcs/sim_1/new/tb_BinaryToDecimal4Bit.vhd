LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY tb_BinaryToDecimal4Bit IS
END tb_BinaryToDecimal4Bit;

ARCHITECTURE Behavioral OF tb_BinaryToDecimal4Bit IS

  COMPONENT BinaryToDecimal4Bit IS
    PORT (
      binary_in : IN UNSIGNED(7 DOWNTO 0);
      decimal_out : OUT STD_LOGIC_VECTOR(11 DOWNTO 0));
  END COMPONENT;

  SIGNAL binary_in : UNSIGNED(7 DOWNTO 0) := (OTHERS => '0');
  SIGNAL decimal_out : STD_LOGIC_VECTOR(11 DOWNTO 0);

  CONSTANT period : TIME := 1ns;

BEGIN

uut: BinaryToDecimal4Bit PORT MAP (
  binary_in => binary_in,
  decimal_out => decimal_out);

stim_binary_in: PROCESS
BEGIN
  WAIT FOR period;
  binary_in <= binary_in + 1;
END PROCESS;

END Behavioral;