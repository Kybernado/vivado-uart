`timescale 1ns/1ps

module uart #(
    parameter CLK_FREQ = 12000000,
    parameter BAUD_RATE = 115200
)(
    input logic s_clk_i,
    input logic s_rst_n_i,
    
    // RX
    output logic [7:0] s_data_o,
    input logic s_rx_i,
    output logic r_data_valid_o,
    
    // TX 
    input logic [7:0] s_data_i,
    output logic r_tx_o,
    input logic s_send_i
);
    
    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) rx0 (
        .s_clk_i(s_clk_i),
        .s_rst_n_i(s_rst_n_i),
        .s_rx_i(s_rx_i),
        .s_data_o(s_data_o),
        .r_data_valid_o(r_data_valid_o) 
    );
    
    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) tx0 (
       .s_clk_i(s_clk_i),
       .s_rst_n_i(s_rst_n_i),
       .s_send_i(s_send_i),
	   .s_data_i(s_data_i),
	   .r_tx_o(r_tx_o)
    );

endmodule