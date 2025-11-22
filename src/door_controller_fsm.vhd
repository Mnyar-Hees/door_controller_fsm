----------------------------------------------------------------------------------
-- Engineer: Mnyar Hees
--
-- File: door_controller_fsm.vhd
--
-- Description:
--   Finite State Machine (FSM) for an automatic door control system.
--   The system supports four states:
--       - OPEN
--       - CLOSED
--       - LOCKED
--       - ERROR
--
--   Inputs are synchronized using two flip-flops to avoid metastability.
--   The door can be opened, closed, locked, or unlocked using SW(0..3).
--   Invalid actions (attempting to open/close while locked) force the FSM
--   into an ERROR state, which can only be cleared by reset.
--
-- Inputs:
--   clk      : 50 MHz system clock
--   reset_n  : Active-low reset
--   SW(0)    : CLOSE request
--   SW(1)    : OPEN request
--   SW(2)    : LOCK request
--   SW(3)    : UNLOCK request
--
-- Outputs:
--   led(0)   : Indicates OPEN state
--   led(1)   : Indicates CLOSED state
--   led(2)   : Indicates LOCKED state
--             ERROR state lights all LEDs (111)
--
--   state    : Binary encoded current state (00=open, 01=closed,
--              10=locked, 11=error) – useful for testbench and waveform validation.
--
-- Notes:
--   - Fully synchronous FSM (except input synchronization).
--   - All inputs except clk are synchronized using 2-FF synchronizers.
--   - ERROR state is latched until reset.
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity door_controller_fsm is
   port (
      clk      : in  std_logic;                      -- System clock
      reset_n  : in  std_logic;                      -- Active-low reset
      SW       : in  std_logic_vector(3 downto 0);   -- Input switches
      led      : out std_logic_vector(2 downto 0);   -- LED state indicators
      state    : out std_logic_vector(1 downto 0)    -- Binary state output
   );
end entity;

architecture rtl of door_controller_fsm is

   --------------------------------------------------------------------
   -- State declaration
   --------------------------------------------------------------------
   type state_type is (state_open, state_closed, state_locked, state_error);
   signal state_internal : state_type;

   --------------------------------------------------------------------
   -- Input synchronizer signals (two-stage flip-flops)
   --------------------------------------------------------------------
   signal reset_n_t1, reset_n_t2 : std_logic;
   signal SW0_t1, SW0_t2 : std_logic;     -- Close
   signal SW1_t1, SW1_t2 : std_logic;     -- Open
   signal SW2_t1, SW2_t2 : std_logic;     -- Lock
   signal SW3_t1, SW3_t2 : std_logic;     -- Unlock

begin

   --------------------------------------------------------------------
   -- Main FSM process
   --------------------------------------------------------------------
   demo_process : process (reset_n_t2, clk)
   begin
      if reset_n_t2 = '0' then
         state_internal <= state_open;

      elsif rising_edge(clk) then
         case state_internal is

            ----------------------------------------------------------------
            -- OPEN  → can only CLOSE
            ----------------------------------------------------------------
            when state_open =>
               if SW0_t2 = '1' then
                  state_internal <= state_closed;
               end if;

            ----------------------------------------------------------------
            -- CLOSED → can OPEN or LOCK
            ----------------------------------------------------------------
            when state_closed =>
               if SW1_t2 = '1' then
                  state_internal <= state_open;
               elsif SW2_t2 = '1' then
                  state_internal <= state_locked;
               end if;

            ----------------------------------------------------------------
            -- LOCKED → can only UNLOCK, invalid actions → ERROR
            ----------------------------------------------------------------
            when state_locked =>
               if SW3_t2 = '1' then
                  state_internal <= state_closed;
               elsif SW0_t2 = '1' or SW1_t2 = '1' then
                  state_internal <= state_error;
               end if;

            ----------------------------------------------------------------
            -- ERROR → Only reset can clear
            ----------------------------------------------------------------
            when state_error =>
               state_internal <= state_error;

            when others =>
               state_internal <= state_open;
         end case;
      end if;
   end process;

   --------------------------------------------------------------------
   -- Binary-encoded state output (for debugging / testbench use)
   --------------------------------------------------------------------
   state <= "00" when state_internal = state_open else
            "01" when state_internal = state_closed else
            "10" when state_internal = state_locked else
            "11";

   --------------------------------------------------------------------
   -- LED output decoder based on state
   --------------------------------------------------------------------
   output_leds : process(state_internal)
   begin
      case state_internal is
         when state_open   => led <= "001";  -- LED0 ON
         when state_closed => led <= "010";  -- LED1 ON
         when state_locked => led <= "100";  -- LED2 ON
         when state_error  => led <= "111";  -- All LEDs ON (error)
      end case;
   end process;

   --------------------------------------------------------------------
   -- Reset synchronizer (2-FF)
   --------------------------------------------------------------------
   reset_n_process : process(clk, reset_n)
   begin
      if reset_n = '0' then
         reset_n_t1 <= '0';
         reset_n_t2 <= '0';
      elsif rising_edge(clk) then
         reset_n_t1 <= '1';
         reset_n_t2 <= reset_n_t1;
      end if;
   end process;

   --------------------------------------------------------------------
   -- Input synchronizers (same structure for all SWx)
   --------------------------------------------------------------------
   SW0_process : process(clk, SW(0))
   begin
      if SW(0) = '0' then
         SW0_t1 <= '0';
         SW0_t2 <= '0';
      elsif rising_edge(clk) then
         SW0_t1 <= SW(0);
         SW0_t2 <= SW0_t1;
      end if;
   end process;

   SW1_process : process(clk, SW(1))
   begin
      if SW(1) = '0' then
         SW1_t1 <= '0';
         SW1_t2 <= '0';
      elsif rising_edge(clk) then
         SW1_t1 <= SW(1);
         SW1_t2 <= SW1_t1;
      end if;
   end process;

   SW2_process : process(clk, SW(2))
   begin
      if SW(2) = '0' then
         SW2_t1 <= '0';
         SW2_t2 <= '0';
      elsif rising_edge(clk) then
         SW2_t1 <= SW(2);
         SW2_t2 <= SW2_t1;
      end if;
   end process;

   SW3_process : process(clk, SW(3))
   begin
      if SW(3) = '0' then
         SW3_t1 <= '0';
         SW3_t2 <= '0';
      elsif rising_edge(clk) then
         SW3_t1 <= SW(3);
         SW3_t2 <= SW3_t1;
      end if;
   end process;

end architecture;
