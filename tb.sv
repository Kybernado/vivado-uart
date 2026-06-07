`timescale 1ns/1ps

`define CLK_FREQ_MHZ 12
`define BAUD_RATE 115200
`define CLK_PERIOD (1000.0/`CLK_FREQ_MHZ)

module uart_tb;

    logic s_clk_i;
    logic s_rst_n_i;
    
    wire s_x;
    logic s_send_i;
    logic s_data_valid_o;
    
	logic [7:0] s_data_i;
	logic [7:0] s_data_o;
    
    uart #(
        .CLK_FREQ(`CLK_FREQ_MHZ*1000000),
        .BAUD_RATE(`BAUD_RATE)
    ) dut (
        .s_clk_i(s_clk_i),
        .s_rst_n_i(s_rst_n_i),
        .s_data_o(s_data_o),
        .s_rx_i(s_x),
        .r_data_valid_o(s_data_valid_o),
        .s_data_i(s_data_i),
        .r_tx_o(s_x),
        .s_send_i(s_send_i)
    );
    
    initial s_clk_i = 0;
    always #(`CLK_PERIOD/2) s_clk_i = ~s_clk_i;
    
    initial begin
        
        s_rst_n_i = 1'b0;
        #100; s_rst_n_i = 1'b1;
        #100;
        
        s_data_i = 8'b11011011;
        s_send_i = 1'b1;
        #100; s_send_i = 1'b0;
        
        wait(s_data_valid_o === 1'b1);
        $display("Input data: %h (%b), output data: %h (%b)", s_data_i, s_data_i, s_data_o, s_data_o);
        assert(s_data_i == s_data_o)
        else begin
            $error("FAIL: Sent data does not match received data.");
            $stop;
        end
        
        #2000;
        
        $display("PASS");
        $finish;
    
    end

endmodule