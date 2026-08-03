# UART Design and Layered SystemVerilog Testbench

## Overview

This repository contains a **UART (Universal Asynchronous Receiver Transmitter)** implementation in **SystemVerilog** along with a **layered verification environment**. The project demonstrates transaction-based verification using object-oriented programming concepts such as classes, mailboxes, virtual interfaces, and self-checking scoreboards.

The UART supports serial transmission and reception with a configurable baud rate generator. The verification environment automatically generates random transactions, drives the DUT, monitors the output, and checks functional correctness.

---

## Features

### RTL Design

* UART Transmitter (TX)
* UART Receiver (RX)
* Configurable Baud Rate Generator (50 MHz → 9600 bps)
* UART Top Module

### Verification Environment

* Layered Testbench Architecture
* Random Transaction Generator
* Driver
* Monitor
* Scoreboard
* Environment
* Test Class
* Virtual Interface
* Mailbox Communication
* Self-Checking Verification

---

## Project Structure

```text
UART-Layered-Testbench/
│
├── rtl/
│   ├── uart_if.sv
│   ├── baud_gen.sv
│   ├── uart_tx.sv
│   ├── uart_rx.sv
│   └── uart_top.sv
│
├── tb/
│   ├── uart_pkg.sv
│   │   ├── uart_transaction
│   │   ├── uart_generator
│   │   ├── uart_driver
│   │   ├── uart_monitor
│   │   ├── uart_scoreboard
│   │   ├── uart_environment
│   │   └── uart_test
│   │
│   └── tb_top.sv
│
└── README.md
```
## Verification Architecture

```text
                 +----------------+
                 |   Generator    |
                 +----------------+
                         |
                    gen2drv Mailbox
                         |
                 +----------------+
                 |     Driver     |
                 +----------------+
                         |
                  Virtual Interface
                         |
                 +----------------+
                 |    UART DUT    |
                 +----------------+
                         |
                  Virtual Interface
                         |
                 +----------------+
                 |    Monitor     |
                 +----------------+
                         |
                    mon2scb Mailbox
                         |
                 +----------------+
                 |   Scoreboard   |
                 +----------------+
                         ^
                         |
                  drv2scb Mailbox
```

---

## Testbench Components

### UART Interface (`uart_if`)

Provides a common communication interface between the DUT and verification components.

### Transaction

Stores transmitted and received data.

### Generator

* Creates random 8-bit UART data.
* Sends transactions to the driver using a mailbox.

### Driver

* Applies generated transactions to the DUT.
* Controls reset and transmission.
* Sends expected data to the scoreboard.

### Monitor

* Observes UART receiver output.
* Captures received data.
* Sends actual data to the scoreboard.

### Scoreboard

* Compares transmitted and received data.
* Displays PASS or FAIL results.
* Maintains pass/fail counters.

### Environment

Instantiates and connects all verification components.

### Test

Starts the complete verification environment.

---

## UART Configuration

| Parameter       | Value           |
| --------------- | --------------- |
| Clock Frequency | 50 MHz          |
| Baud Rate       | 9600 bps        |
| Data Bits       | 8               |
| Start Bit       | 1               |
| Stop Bit        | 1               |
| Parity          | Not Implemented |

---

## Simulation Flow

1. Reset DUT
2. Generator creates random data.
3. Driver transmits data through UART TX.
4. TX serial output is looped back to RX input.
5. Monitor captures received data.
6. Scoreboard compares expected and actual data.
7. PASS/FAIL message is displayed.

---

## Tools Used

* **Language:** SystemVerilog
* **Verification Methodology:** Layered Testbench
* **Simulator:** QuestaSim / ModelSim

---

## Running the Simulation

Compile:

```tcl
vlib work
vlog rtl/*.sv
vlog tb/*.sv
vsim tb_top
```

Run:

```tcl
add wave -r *
run -all
```

---

## Sample Output

```text
GEN : DATA = 5A

DRIVER : SENT = 5A

MONITOR : RECEIVED = 5A

SCOREBOARD : PASS
Expected = 5A
Received = 5A
```

---

## Concepts Demonstrated

* UART Protocol
* RTL Design
* Layered Verification
* Object-Oriented SystemVerilog
* Mailboxes
* Virtual Interfaces
* Randomized Stimulus
* Functional Verification
* Self-Checking Testbench

---

## Future Improvements

* Configurable Baud Rate
* Parity Bit Support (Even/Odd)
* Multiple Stop Bits
* Functional Coverage
* Assertions (SVA)
* UVM-based Verification Environment

---

## Author

**Wamiq Irfan**

ASIC & RTL Engineer 
