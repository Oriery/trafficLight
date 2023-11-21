LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY SevenSegmentDisplay4Digits IS
  PORT (
    num : IN UNSIGNED(7 DOWNTO 0);
    clk : IN STD_LOGIC;
    digit : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    segments : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END SevenSegmentDisplay4Digits;

ARCHITECTURE Behavioral OF SevenSegmentDisplay4Digits IS

  -- Instantiate the BinaryToDecimal4Bit entity
  COMPONENT BinaryToDecimal4Bit
    PORT (
      binary_in : IN UNSIGNED(7 DOWNTO 0);
      decimal_out : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
    );
  END COMPONENT;

  -- Segment encoding for numbers 0-9
  FUNCTION encode_digit(digit : INTEGER) RETURN STD_LOGIC_VECTOR IS
  BEGIN
    CASE digit IS
      WHEN 0 => RETURN "00000011"; -- 0
      WHEN 1 => RETURN "10011111"; -- 1
      WHEN 2 => RETURN "00100101"; -- 2
      WHEN 3 => RETURN "00001101"; -- 3
      WHEN 4 => RETURN "10011001"; -- 4
      WHEN 5 => RETURN "01001001"; -- 5
      WHEN 6 => RETURN "01000001"; -- 6
      WHEN 7 => RETURN "00011111"; -- 7
      WHEN 8 => RETURN "00000001"; -- 8
      WHEN 9 => RETURN "00001001"; -- 9
      WHEN OTHERS => RETURN "11111111"; -- Show nothing if digit is not 0-9
    END CASE;
  END FUNCTION;

  SIGNAL decimal_number_short : UNSIGNED(11 DOWNTO 0);
  SIGNAL decimal_number : UNSIGNED(15 DOWNTO 0);
  SIGNAL current_digit : INTEGER RANGE 0 TO 3 := 0;
  SIGNAL digit_temp : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
  SIGNAL segments_temp : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
  SIGNAL nonZeroDigits : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
  SIGNAL digitShouldWork : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '1');

BEGIN
  -- Binary to Decimal conversion
  BinaryToDecimal4Bit_instance : BinaryToDecimal4Bit
  PORT MAP(
    binary_in => num,
    STD_LOGIC_VECTOR(decimal_out) => decimal_number_short
  );
  decimal_number <= "0000" & decimal_number_short;

  -- set which digits are zeros
  nonZeroDigits(0) <= '0' WHEN decimal_number(3 DOWNTO 0) = 0 ELSE
  '1';
  nonZeroDigits(1) <= '0' WHEN decimal_number(7 DOWNTO 4) = 0 ELSE
  '1';
  nonZeroDigits(2) <= '0' WHEN decimal_number(11 DOWNTO 8) = 0 ELSE
  '1';
  nonZeroDigits(3) <= '0' WHEN decimal_number(15 DOWNTO 12) = 0 ELSE
  '1';

  -- do not show leading zeros
  digitShouldWork(0) <= '1'; -- smallest digit always works
  digitShouldWork(1) <= '0' WHEN nonZeroDigits(3 DOWNTO 1) = "000" ELSE
  '1';
  digitShouldWork(2) <= '0' WHEN nonZeroDigits(3 DOWNTO 2) = "00" ELSE
  '1';
  digitShouldWork(3) <= '0' WHEN nonZeroDigits(3) = '0' ELSE
  '1';

  PROCESS (clk)
  BEGIN
    IF rising_edge(clk) THEN
      -- Switch to the next digit
      current_digit <= (current_digit + 1) MOD 4;

      -- Use a case statement to activate the current digit
      CASE current_digit IS
        WHEN 0 =>
          digit_temp <= "1110"; -- Activate first digit
        WHEN 1 =>
          digit_temp <= "1101"; -- Activate second digit
        WHEN 2 =>
          digit_temp <= "1011"; -- Activate third digit
        WHEN 3 =>
          digit_temp <= "0111"; -- Activate fourth digit
        WHEN OTHERS =>
          digit_temp <= (OTHERS => '1'); -- Default case
      END CASE;

      IF digitShouldWork(current_digit) = '1' THEN
        -- Set segments for current digit
        segments_temp <= encode_digit(to_integer(unsigned(decimal_number(current_digit * 4 + 3 DOWNTO current_digit * 4))));
      ELSE
        -- Set segments to show nothing
        segments_temp <= "11111111";
      END IF;
    END IF;
  END PROCESS;

  digit <= digit_temp;
  segments <= segments_temp;
END Behavioral;