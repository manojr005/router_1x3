# Router 1x3 RTL Design

A synthesizable **Router 1x3** implemented in **Verilog HDL** that routes incoming network packets from a single source to one of three destination networks based on the destination address. The design follows a **packet-based communication protocol**, includes **FIFO buffering**, **flow control**, and **parity-based error detection**, making it suitable for digital design and ASIC/FPGA learning.

---

## Project Overview

The Router 1x3 receives packets from a single source network through an 8-bit data interface and forwards them to one of three destination networks. Each destination has an independent FIFO, allowing simultaneous packet reads while accepting only one packet at a time from the source.

The router supports:

- Packet-based communication
- Dynamic packet routing
- Independent FIFOs for each destination
- Flow control using **busy**
- Packet validity indication
- Parity-based error detection

---



## Features

- Single source to three destination routing
- 8-bit packet interface
- Packet-based protocol
- Three independent FIFOs
- Simultaneous read from all destination FIFOs
- Busy signal for flow control
- Packet validity indication
- Parity generation and verification
- Error detection for corrupted packets
- Active-low synchronous reset
- Fully synthesizable Verilog RTL

---

## Packet Format

Each packet consists of:

| Field | Size |
|--------|------|
| Header | 1 Byte |
| Payload | 1–63 Bytes |
| Parity | 1 Byte |

### Header Format

| Bits | Description |
|------|-------------|
| [7:2] | Payload Length |
| [1:0] | Destination Address |

Destination Address Encoding:

| Address | Destination FIFO |
|----------|------------------|
| 00 | FIFO 0 |
| 01 | FIFO 1 |
| 10 | FIFO 2 |
| 11 | Invalid Address |

---

## Interface

### Inputs

| Signal | Width | Description |
|---------|------|-------------|
| clock | 1 | System clock |
| resetn | 1 | Active-low synchronous reset |
| data_in | 8 | Input packet data |
| pkt_valid | 1 | Indicates valid packet transmission |
| read_enb_0 | 1 | Read enable for FIFO 0 |
| read_enb_1 | 1 | Read enable for FIFO 1 |
| read_enb_2 | 1 | Read enable for FIFO 2 |

---

### Outputs

| Signal | Width | Description |
|---------|------|-------------|
| data_out_0 | 8 | Data output from FIFO 0 |
| data_out_1 | 8 | Data output from FIFO 1 |
| data_out_2 | 8 | Data output from FIFO 2 |
| valid_out_0 | 1 | FIFO 0 contains valid packet |
| valid_out_1 | 1 | FIFO 1 contains valid packet |
| valid_out_2 | 1 | FIFO 2 contains valid packet |
| busy | 1 | Router busy indication |
| error | 1 | Parity mismatch detected |

---

## Working Principle

### Packet Reception

- The source transmits one byte per clock cycle.
- The first byte is the header.
- `pkt_valid` remains HIGH during header and payload transmission.
- `pkt_valid` goes LOW while transmitting the parity byte.

---

### Routing

The router extracts the destination address from the header and stores the incoming packet into the corresponding FIFO.

- Address `00` → FIFO 0
- Address `01` → FIFO 1
- Address `10` → FIFO 2

---

### Flow Control

If the selected FIFO becomes full, the router asserts:

```
busy = 1
```

The source must stop transmitting until `busy` is de-asserted.

---

### Packet Read

Each destination continuously monitors:

```
valid_out_x
```

When asserted, the destination enables

```
read_enb_x
```

and reads packet bytes from

```
data_out_x
```

---

### Error Detection

The router calculates the parity internally while receiving the packet.

At the end of the packet:

```
Received Parity == Calculated Parity ?
```

- Match → Packet accepted
- Mismatch → `error` asserted

---

## Design Architecture

The design is divided into the following RTL modules:

```
Router Top
│
├── FSM Controller
├── Register Block
├── Synchronizer
├── FIFO 0
├── FIFO 1
└── FIFO 2
```

### FSM Controller

Responsible for:

- Packet reception
- FIFO write control
- Busy handling
- Parity completion
- State transitions

---

### Synchronizer

Responsible for:

- Decoding destination address
- Selecting FIFO
- Generating write enable
- Monitoring FIFO status

---

### Register Block

Responsible for:

- Header storage
- Payload storage
- Parity generation
- Error detection

---

### FIFO

Each FIFO stores packets independently and supports:

- Write operation
- Read operation
- Full detection
- Empty detection

---

## Protocol Timing

### Packet Transmission

```
Clock

Header
Payload Byte 1
Payload Byte 2
...
Payload Byte N
Parity

pkt_valid

───────────────┐
               │
───────────────┘
```

The parity byte is transmitted after `pkt_valid` becomes LOW.

---

## Project Directory

```
Router_1x3/
│
├── rtl/
│   ├── router_top.v
│   ├── router_fsm.v
│   ├── router_fifo.v
│   ├── router_reg.v
│   └── router_sync.v
│
├── testbench/
│   └── router_tb.v
│
├── docs/
│   └── router_block_diagram.png
│
└── README.md
```

---

## Simulation

The design can be simulated using:

- ModelSim
- QuestaSim
- Xilinx Vivado Simulator
- Cadence Xcelium
- Synopsys VCS
- Icarus Verilog

Example:

```bash
iverilog *.v
vvp a.out
gtkwave dump.vcd
```

---

## Applications

- Network-on-Chip (NoC)
- FPGA communication systems
- Packet switching
- Digital communication systems
- ASIC Design Training
- RTL Design Practice

---



## Author

**Manoj R**

Aspiring RTL Design / VLSI Engineer

- Verilog HDL
- Digital Design
- ASIC Front-End Design
- FPGA Development

---
