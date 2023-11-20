LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY clock_divider IS
  GENERIC (
    divider : INTEGER := 100000000
  );
  PORT (
    clk_in : IN STD_LOGIC;
    clk_out : OUT STD_LOGIC
  );
END clock_divider;

ARCHITECTURE Behavioral OF clock_divider IS
  SIGNAL counter : INTEGER := 0;
  SIGNAL tmp_clk_out : STD_LOGIC := '0';
BEGIN
  PROCESS (clk_in)
  BEGIN
    IF rising_edge(clk_in) THEN
      IF counter < (divider / 2 - 1) THEN
        counter <= counter + 1;
      ELSE
        counter <= 0;
        tmp_clk_out <= NOT tmp_clk_out;
      END IF;
    END IF;
  END PROCESS;

  clk_out <= tmp_clk_out;
END Behavioral;