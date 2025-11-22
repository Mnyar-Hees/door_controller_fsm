library ieee;
use ieee.std_logic_1164.all;

--=============================================================
-- Testbench for: door_controller_fsm
-- Description:
--   This testbench verifies basic state transitions of the
--   door controller finite state machine (FSM). It applies
--   input stimuli representing OPEN/CLOSE/LOCK/UNLOCK commands
--   and observes the resulting LEDs and state outputs.
--=============================================================
entity door_controller_fsm_tb is
end entity;

architecture test of door_controller_fsm_tb is

    -- Testbench signals
    signal clk     : std_logic := '0';
    signal reset_n : std_logic := '1';
    signal SW      : std_logic_vector(3 downto 0) := "0000";
    signal led     : std_logic_vector(2 downto 0);
    signal state   : std_logic_vector(1 downto 0);

    ----------------------------------------------------------------
    -- Component declaration for Unit Under Test (UUT)
    -- Must match the entity defined in the RTL design
    ----------------------------------------------------------------
    component door_controller_fsm
        port (
            clk      : in  std_logic;
            reset_n  : in  std_logic;
            SW       : in  std_logic_vector(3 downto 0);
            led      : out std_logic_vector(2 downto 0);
            state    : out std_logic_vector(1 downto 0)
        );
    end component;

begin

    ----------------------------------------------------------------
    -- Instantiate the UUT
    ----------------------------------------------------------------
    uut: door_controller_fsm
        port map (
            clk      => clk,
            reset_n  => reset_n,
            SW       => SW,
            led      => led,
            state    => state
        );

    ----------------------------------------------------------------
    -- Clock generation: 50 MHz equivalent (20 ns period)
    ----------------------------------------------------------------
    clk_process : process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    ----------------------------------------------------------------
    -- Stimulus process: apply test scenarios
    ----------------------------------------------------------------
    stimulus : process
    begin
        -- Apply reset
        reset_n <= '0';
        wait for 30 ns;
        reset_n <= '1';
        wait for 30 ns;

        -- Test CLOSE (SW0)
        SW <= "0001";   -- CLOSE command
        wait for 60 ns;

        -- Test OPEN (SW1)
        SW <= "0010";   -- OPEN command
        wait for 60 ns;

        -- Test LOCK (SW2)
        SW <= "0100";   -- LOCK command
        wait for 60 ns;

        -- Test UNLOCK (SW3)
        SW <= "1000";   -- UNLOCK command
        wait for 60 ns;

        -- End simulation
        wait;
    end process;

end architecture;
