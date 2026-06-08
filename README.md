# vivado-uart

This is an implementation of UART protocol in SystemVerilog in Vivado for Artix-7 based Cmod A7-35T FPGA board.

## Architecture

```
uart_top (uart_top.sv)     - board wrapper, Clock Wizard IP, reset logic wrapper
  - uart (uart.sv)     - UART logic wrapper
    - uart_tx    - transmitter with baud rate generator
    - uart_rx    - receiver with async start bit detection
```

<img width="2045" height="629" alt="image" src="https://github.com/user-attachments/assets/b7c9d136-a5e0-45c3-bf92-a5be65cb25b1" />

`uart` (uart.sv) acts as top level module for logic - for the UART itself, and it consists of TX and RX part, instantiated one by one. `uart_top` module is there as a bridge between the FPGA board and the UART logic - it uses a Clock Wizard IP block to route the on-board clock to the UART module, and ties the UART reset to the PLL `locked` signal so the UART stays in reset until the clock is stable.

The schematic shows the internal structure of uart_top, including the Clock Wizard IP and UART submodule connections.

## Features
- Configurable baud rate and clock frequency through module parameters
- Asynchronous detection of start bit on native clock
- Sampling in middle of bits in RX line
- `data_valid` pulse signal

## Simulation

Behavioral simulation was done in Vivado integrated simulator.

There are testbenches for both TX and RX, and then for the top level UART module.

TX and RX were verified independently — TX testbench checks bit ordering, baud rate timing, and start/stop bit generation. RX testbench verifies correct byte reconstruction from a serial bitstream.

The UART module testbench acts as a loopback — TX and RX are connected against each other on a single wire. TX transmits data, RX captures it, and the testbench verifies that the received data matches the transmitted data.

RTL correctness has been verified through simulation.

## Synthesis results

Target: Digilent Cmod A7-35T (xc7a35tcpg236-1), Vivado 2025.2

| Resource | Used | Available | Utilization |
|----------|------|-----------|-------------|
| LUT      | 49   | 20800     | 0.24%       |
| FF       | 34   | 41600     | 0.08%       |
| IO       | 22   | 106       | 20.75%      |
| MMCM     | 1    | 5         | 20%         |

Timing: WNS = 75.434 ns — all constraints met. Theoretical max frequency ~126 MHz.

Power: 0.176 W total (0.104 W MMCM, <0.001 W logic)

ILA (Integrated Logic Analyzer) is included in the bitstream for in-circuit debugging of `r_state`, `r_clk_count`, and `r_tx_o` signals via Vivado Hardware Manager.

## Pin mapping (Cmod A7-35T)

| Signal         | Pin            | Description               |
|----------------|----------------|---------------------------|
| s_clk_i        | L17            | 12 MHz on-board crystal   |
| s_rst_i        | A18            | BTN0, active high         |
| r_tx_o         | J18            | USB-UART bridge TX        |
| s_rx_i         | J17            | USB-UART bridge RX        |
| r_data_valid_o | A17            | LED0 — blinks on RX       |
| s_data_o[7:0]  | PMOD JA        | Received byte output      |
| s_data_i[7:0]  | GPIO pio1-pio8 | TX data input             |
| s_send_i       | GPIO pio17     | TX trigger                |

## How to use

To use it in other projects, instantiate `uart.sv` with parameters:

```systemverilog
uart #(
    .CLK_FREQ(<your clock frequency>),
    .BAUD_RATE(<your baud rate>)
) uart_inst (
    .s_clk_i(clk),
    .s_rst_n_i(rst_n),
    .s_rx_i(rx),
    .r_tx_o(tx),
    .s_data_i(data_to_send),
    .s_send_i(send_trigger),
    .s_data_o(received_data),
    .r_data_valid_o(data_valid)
);
```

To flash on an FPGA board, use `uart_top.sv` as the synthesis top module in Vivado, as it includes the Clock Wizard IP for clock management. Then connect via PuTTY or TeraTerm at 115200 baud. TX and RX are independent — loopback requires an external connection, software echo, or connecting them in the top level module.

## Note

This project has not yet been tested on real FPGA hardware.

It has been verified through behavioral simulation only, and all synthesis and post-implementation data are taken from Vivado reports.

Testing on Cmod A7-35T is planned once the board arrives.
