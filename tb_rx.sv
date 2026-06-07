`timescale 1ns/1ps

`define CLK_FREQ_MHZ 10
`define BAUD_RATE 115200
`define CLK_PERIOD (1000.0/`CLK_FREQ_MHZ)
`define CLKS_PER_BIT ((`CLK_FREQ_MHZ * 1000000) / `BAUD_RATE)
`define BAUD_PERIOD (`CLKS_PER_BIT * `CLK_PERIOD)

module uart_rx_tb;
    
    logic s_clk_i;
    logic s_rst_n_i;
    logic s_rx_i;
    logic [7:0] s_data_o;
    logic r_data_valid_o;
    
    task receive_byte(logic [7:0] data);
        
        s_rx_i = 1'b0;
        #`BAUD_PERIOD;
        
        for(int i=0; i<8; i++) begin
            s_rx_i = data[i];
            #`BAUD_PERIOD;
        end
        
        wait(r_data_valid_o === 1'b1);
        
        $display("Received data: %h (%b), expected data: %h (%b).", s_data_o, s_data_o, data, data);
        assert(s_data_o == data)
        else begin
            $error("FAIL: Expected data doesn't match received data.");
            $stop;
        end
        
        s_rx_i = 1'b1;
        #`BAUD_PERIOD;
        
    endtask
    
    uart_rx #(
        .CLK_FREQ(`CLK_FREQ_MHZ*1000000),
        .BAUD_RATE(`BAUD_RATE)
    ) dut (
        .s_clk_i(s_clk_i),
        .s_rst_n_i(s_rst_n_i),
        .s_rx_i(s_rx_i),
        .s_data_o(s_data_o),
        .r_data_valid_o(r_data_valid_o) 
    );
    
    initial s_clk_i = 0;
    always #(`CLK_PERIOD/2) s_clk_i = ~s_clk_i;
    
    initial begin
        
        s_rst_n_i = 0;
        s_rx_i = 1; // idle line is high
        #100; s_rst_n_i = 1;
        #100;
        
        receive_byte(8'b11001001);
        #`BAUD_PERIOD;
        receive_byte(8'b01111010);
        #`BAUD_PERIOD;
        
        $display("PASS");
        $finish;
        
    end

endmodule