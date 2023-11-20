LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY countdown_timer IS
  GENERIC (Bits : INTEGER);
  PORT (
    C : IN STD_LOGIC;
    R_async : IN STD_LOGIC;
    R_sync : IN STD_LOGIC;
    D : IN UNSIGNED(Bits - 1 DOWNTO 0);
    Count : OUT UNSIGNED(Bits - 1 DOWNTO 0));
END countdown_timer;

ARCHITECTURE Behavioral OF countdown_timer IS
  SIGNAL current_count : UNSIGNED(Bits - 1 DOWNTO 0) := (OTHERS => '0');
BEGIN
  PROCESS (C, R_async)
  BEGIN
    IF R_async = '1' THEN
      current_count <= D;
    ELSIF rising_edge(C) THEN
      IF R_sync = '1' THEN
        current_count <= D;
      ELSIF current_count /= 0 THEN
        current_count <= current_count - 1;
      END IF;
    END IF;
  END PROCESS;

  Count <= current_count;
END Behavioral;