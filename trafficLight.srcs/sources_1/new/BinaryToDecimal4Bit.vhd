library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;  -- Updated library

entity BinaryToDecimal4Bit is
    Port ( binary_in : in  UNSIGNED(7 downto 0);
           decimal_out : out STD_LOGIC_VECTOR(11 downto 0));
end BinaryToDecimal4Bit;

architecture Behavioral of BinaryToDecimal4Bit is
begin
    process(binary_in)
        variable decimal_value: integer;  -- Changed to integer
        variable hundreds: UNSIGNED(3 downto 0) := (others => '0');
        variable tens: UNSIGNED(3 downto 0) := (others => '0');
        variable ones: UNSIGNED(3 downto 0) := (others => '0');
    begin
        -- Convert binary to decimal
        decimal_value := to_integer(binary_in);  -- Conversion to integer

        -- Extract hundreds, tens, and ones place
        hundreds := TO_UNSIGNED(decimal_value / 100, 4);
        tens := TO_UNSIGNED((decimal_value mod 100) / 10, 4);
        ones := TO_UNSIGNED(decimal_value mod 10, 4);

        -- Combine to create 12-bit output
        decimal_out <= std_logic_vector(hundreds) & std_logic_vector(tens) & std_logic_vector(ones);
    end process;
end Behavioral;
