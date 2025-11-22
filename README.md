# Door Controller FSM (VHDL)

This repository contains a finite state machine (FSM) implemented in VHDL for controlling an automatic door with integrated lock logic. The design was developed and tested as part of an embedded/FPGA course assignment.

The system supports four states:

- **OPEN**
- **CLOSED**
- **LOCKED**
- **ERROR**

All button inputs are synchronized with two flip-flops to avoid metastability, and the ERROR state can only be cleared by reset.

---

## Features

- Fully synchronous FSM in VHDL  
- 4 states: OPEN, CLOSED, LOCKED, ERROR  
- 2-FF input synchronizers for all external switches  
- LED outputs indicating the current door state  
- Binary-encoded state output (`state(1:0)`) for testbench and waveform inspection  
- ModelSim testbench and DO-file for simulation  
- Technical report included in the repository

---

## I/O Overview

### Inputs

- `clk` – system clock  
- `reset_n` – active-low reset  
- `SW(0)` – CLOSE request  
- `SW(1)` – OPEN request  
- `SW(2)` – LOCK request  
- `SW(3)` – UNLOCK request  

### Outputs

- `led(0)` – door open  
- `led(1)` – door closed  
- `led(2)` – door locked  
- `state(1:0)` – binary state encoding  
  - `00` = OPEN  
  - `01` = CLOSED  
  - `10` = LOCKED  
  - `11` = ERROR  

In the **ERROR** state all three LEDs are lit (`111`).

---

## File Structure

```text
src/
  door_controller_fsm.vhd        -- Main FSM implementation
  door_controller_fsm_tb.vht     -- Testbench for the FSM
  door_controller_fsm_run.do     -- ModelSim DO-file (compilation + simulation)

docs/
  Embedded_System_Door_Controller.pdf  -- Technical report

README.md
