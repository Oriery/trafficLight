LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

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
    ColorSelectorOut : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    TimeTillNextStateOut : OUT UNSIGNED(7 DOWNTO 0)
  );
END trafficLight;

ARCHITECTURE Behavioral OF trafficLight IS

  COMPONENT clock_divider IS
    GENERIC (
      divider : INTEGER
    );
    PORT (
      clk_in : IN STD_LOGIC;
      clk_out : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT mux_2 IS
    PORT (
      A : IN STD_LOGIC;
      B : IN STD_LOGIC;
      S : IN STD_LOGIC;
      Z : OUT STD_LOGIC);
  END COMPONENT;

  COMPONENT mux_4_2 IS
    PORT (
      A : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      B : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      S : IN STD_LOGIC;
      Z : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT demux_4 IS
    PORT (
      I : IN STD_LOGIC;
      S : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      A : OUT STD_LOGIC;
      B : OUT STD_LOGIC;
      C : OUT STD_LOGIC;
      D : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT countdown_timer IS
    GENERIC (Bits : INTEGER);
    PORT (
      C : IN STD_LOGIC;
      R_async : IN STD_LOGIC;
      R_sync : IN STD_LOGIC;
      D : IN UNSIGNED(Bits - 1 DOWNTO 0);
      Count : OUT UNSIGNED(Bits - 1 DOWNTO 0));
  END COMPONENT;

  COMPONENT mux_4_gen_to_1 IS
    GENERIC (
      Bits : INTEGER
    );
    PORT (
      A : IN STD_LOGIC_VECTOR(Bits - 1 DOWNTO 0);
      B : IN STD_LOGIC_VECTOR(Bits - 1 DOWNTO 0);
      C : IN STD_LOGIC_VECTOR(Bits - 1 DOWNTO 0);
      D : IN STD_LOGIC_VECTOR(Bits - 1 DOWNTO 0);
      S : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      Y : OUT STD_LOGIC_VECTOR(Bits - 1 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT TwoStepDFF IS
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      D : IN STD_LOGIC;
      Q : OUT STD_LOGIC);
  END COMPONENT;

  -- Common signals
  SIGNAL clkDivided : STD_LOGIC;
  SIGNAL notClkDivided : STD_LOGIC;
  SIGNAL yellow : STD_LOGIC;
  -- Select color
  SIGNAL state : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00"; -- 00 = green, 01 = yellow, 10 = red, 11 = redYellow
  SIGNAL nextState : STD_LOGIC_VECTOR(1 DOWNTO 0) := "01";
  SIGNAL colorSelector : STD_LOGIC_VECTOR(1 DOWNTO 0); -- like state but can be forced to yellow '01' when traffic light is off
  SIGNAL wantGreen : STD_LOGIC;
  SIGNAL wantYellow : STD_LOGIC;
  SIGNAL wantRed : STD_LOGIC;
  SIGNAL wantRedYellow : STD_LOGIC;
  -- Countdown timer
  SIGNAL timeTillNextState : UNSIGNED(7 DOWNTO 0);
  SIGNAL lengthOfNextState : UNSIGNED(7 DOWNTO 0);
  SIGNAL shouldChangeState : STD_LOGIC := '0';
  -- Blinking
  SIGNAL shouldBlink : STD_LOGIC;
  SIGNAL lightIsOn : STD_LOGIC;
  -- Lengths of states
  SIGNAL lengthOfGreen : UNSIGNED(7 DOWNTO 0) := "00001000"; -- 8
  CONSTANT lengthOfYellow : UNSIGNED(7 DOWNTO 0) := "00000011"; -- 3
  SIGNAL lengthOfRed : UNSIGNED(7 DOWNTO 0) := "00000100"; -- 4
  CONSTANT lengthOfRedYellow : UNSIGNED(7 DOWNTO 0) := "00000010"; -- 2

BEGIN
  -- slow down clk to be 1Hz
  slowDownClk : clock_divider
  GENERIC MAP(
    divider => 100000000 -- TODO: change to 100000000 when using real system clock
  )
  PORT MAP(
    clk_in => Clk,
    clk_out => clkDivided
  );

  -- calc next state
  nextState <= unsigned(state) + 1;

  -- set colorSelector
  setColorSelector : mux_4_2
  PORT MAP(
    A => "01",
    B => state,
    S => IsOn,
    Z => colorSelector
  );

  -- set wanted color
  setWantedColor : demux_4
  PORT MAP(
    I => lightIsOn,
    S => colorSelector,
    A => wantGreen,
    B => wantYellow,
    C => wantRed,
    D => wantRedYellow
  );

  -- set length of next state
  setLengthOfNextState : mux_4_gen_to_1
  GENERIC MAP(
    Bits => 8
  )
  PORT MAP(
    A => STD_LOGIC_VECTOR(lengthOfGreen),
    B => STD_LOGIC_VECTOR(lengthOfYellow),
    C => STD_LOGIC_VECTOR(lengthOfRed),
    D => STD_LOGIC_VECTOR(lengthOfRedYellow),
    S => nextState,
    STD_LOGIC_VECTOR(Y) => lengthOfNextState
  );

  -- countdown timer
  timer : countdown_timer
  GENERIC MAP(
    Bits => 8
  )
  PORT MAP(
    C => clkDivided,
    R_sync => '0',
    R_async => shouldChangeState,
    D => lengthOfNextState,
    Count => timeTillNextState
  );

  -- set shouldChangeState
  PROCESS (timeTillNextState, Clk)
  BEGIN
    IF (timeTillNextState = 0) THEN
      shouldChangeState <= '1';
    ELSif falling_edge(Clk) THEN
      shouldChangeState <= '0';
    END IF;
  END PROCESS;

  -- set shouldBlink
  shouldBlink <= '1' WHEN ((state = "00" AND timeTillNextState < 4) OR IsOn = '0') ELSE
    '0';

  -- set lightIsOn
  setLightIsOn : mux_2
  PORT MAP(
    A => '1',
    B => notClkDivided,
    S => shouldBlink,
    Z => lightIsOn
  );
  notClkDivided <= NOT clkDivided;

  -- set output
  Red <= wantRed OR wantRedYellow;
  Green <= wantGreen;
  yellow <= wantYellow OR wantRedYellow;
  -- yellow = red + green
  RedOnSecondLed <= yellow;
  GreenOnSecondLed <= yellow;

  -- change state
  changeState0 : TwoStepDFF
  PORT MAP(
    clk => shouldChangeState,
    reset => '0',
    D => nextState(0),
    Q => state(0)
  );
  changeState1 : TwoStepDFF
  PORT MAP(
    clk => shouldChangeState,
    reset => '0',
    D => nextState(1),
    Q => state(1)
  );

  -- for debugging:
  IsOnOut <= IsOn;
  ClkDividedOut <= clkDivided;
  ColorSelectorOut <= colorSelector;
  TimeTillNextStateOut <= timeTillNextState;
END Behavioral;