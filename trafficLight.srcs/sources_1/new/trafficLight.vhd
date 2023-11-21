LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

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
    TimeTillNextStateOut : OUT UNSIGNED(7 DOWNTO 0);
    SegmentsSelector : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    DigitSelector : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
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

  COMPONENT SevenSegmentDisplay4Digits IS
    PORT (
      num : IN UNSIGNED(7 DOWNTO 0);
      clk : IN STD_LOGIC;
      digit : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      segments : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
  END COMPONENT;

  -- Common signals
  SIGNAL clkDivided : STD_LOGIC;
  SIGNAL notClkDivided : STD_LOGIC;
  SIGNAL yellow : STD_LOGIC;
  -- Select color
  SIGNAL state : STD_LOGIC_VECTOR(1 DOWNTO 0); -- 00 = green, 01 = yellow, 10 = red, 11 = redYellow
  SIGNAL nextState : STD_LOGIC_VECTOR(1 DOWNTO 0);
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
  SIGNAL lengthOfGreen : UNSIGNED(7 DOWNTO 0) := "00001010"; -- 10
  CONSTANT lengthOfYellow : UNSIGNED(7 DOWNTO 0) := "00000011"; -- 3
  SIGNAL lengthOfRed : UNSIGNED(7 DOWNTO 0) := "00000100"; -- 4
  CONSTANT lengthOfRedYellow : UNSIGNED(7 DOWNTO 0) := "00000010"; -- 2
  -- Display
  SIGNAL digitSelector_temp : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL clkDividedForDisplay : STD_LOGIC;
  SIGNAL shouldDisplay : STD_LOGIC;

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
  nextState <= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(state)) + 1, state'length));

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
    ELSIF falling_edge(Clk) THEN
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

  -- set clkDividedForDisplay so that display refresh rate is 100Hz. 100Hz * 4 digits = 400Hz. 100M / 400 = 250000
  setClkDividedForDisplay : clock_divider
  GENERIC MAP(
    divider => 250000
  )
  PORT MAP(
    clk_in => Clk,
    clk_out => clkDividedForDisplay
  );

  -- output time on 7 segment display
  outputTime : SevenSegmentDisplay4Digits
  PORT MAP(
    num => timeTillNextState,
    clk => clkDividedForDisplay,
    digit => digitSelector_temp,
    segments => SegmentsSelector
  );
  -- set DigitSelector: only ON when shouldDisplay is true
  DigitSelector <= "1111" & digitSelector_temp WHEN shouldDisplay = '1' ELSE (OTHERS => '1');

  -- set shouldDisplay: when working and (green or red) and light is on
  shouldDisplay <= '1' WHEN (IsOn = '1' AND (wantGreen = '1' OR wantRed = '1') AND lightIsOn = '1') ELSE
    '0';

  -- for debugging:
  IsOnOut <= IsOn;
  ClkDividedOut <= clkDivided;
  ColorSelectorOut <= colorSelector;
  TimeTillNextStateOut <= timeTillNextState;
END Behavioral;