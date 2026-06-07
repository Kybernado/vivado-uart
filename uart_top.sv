`timescale 1ns / 1ps

module uart_top(
    input logic s_clk_i,
    input logic s_rst_i,
    
    // RX
    output logic [7:0] s_data_o,
    input logic s_rx_i,
    output logic r_data_valid_o,
    
    // TX 
    input logic [7:0] s_data_i,
    output logic r_tx_o,
    input logic s_send_i
);
    
    logic s_clk;
    logic locked;
    
    clk_0 clk0 (
      .clk_in1(s_clk_i),
      .clk_out1(s_clk),
      .resetn(~s_rst_i),
      .locked(locked)
    );
    
    uart #(
        .CLK_FREQ(12000000),
        .BAUD_RATE(115200)
    ) uart0 (
        .s_clk_i(s_clk),
        .s_rst_n_i(locked),
        .s_data_o(s_data_o),
        .s_rx_i(s_rx_i),
        .r_data_valid_o(r_data_valid_o),
        .s_data_i(s_data_i),
        .r_tx_o(r_tx_o),
        .s_send_i(s_send_i)
    );

endmodule
