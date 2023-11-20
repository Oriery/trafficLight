LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY increment_by_one IS
  GENERIC (
    vector_length : INTEGER := 2 -- Default length is 2, can be overridden
  );
  PORT (
    input_vector : IN STD_LOGIC_VECTOR(vector_length - 1 DOWNTO 0);
    output_vector : OUT STD_LOGIC_VECTOR(vector_length - 1 DOWNTO 0)
  );
END increment_by_one;

ARCHITECTURE Behavioral OF increment_by_one IS

BEGIN
  PROCESS (input_vector)
  BEGIN
    -- Convert to unsigned, add 1, and then convert back to STD_LOGIC_VECTOR
    -- Resize is used to handle vectors of different lengths
    output_vector <= STD_LOGIC_VECTOR(resize(unsigned(input_vector), vector_length) + 1);
  END PROCESS;
END Behavioral;