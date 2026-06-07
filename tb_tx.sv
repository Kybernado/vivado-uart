`timescale 1ns/1ps

`define CLK_FREQ_MHZ 10
`define BAUD_RATE 115200
`define CLK_PERIOD (1000.0/`CLK_FREQ_MHZ)
`define CLKS_PER_BIT ((`CLK_FREQ_MHZ * 1000000) / `BAUD_RATE)
`define BAUD_PERIOD (`CLKS_PER_BIT * `CLK_PERIOD)

module uart_tx_tb;

    logic s_clk_i;
    logic s_rst_n_i;
    logic s_send_i;
    logic [7:0] s_data_i;
    logic r_tx_o;
    
    task send_byte(logic [7:0] data);
        s_data_i = data;
        s_send_i = 1'b1;
        
        @(negedge r_tx_o); // waiting for start bit
        s_send_i = 1'b0;
        $display("Started transmission of %h (%b) at time %0t", data, data, $time);
        
        #(0.5* `BAUD_PERIOD); // go to middle of bit
        for(int i=0; i<8; i++) begin
            #`BAUD_PERIOD;
            assert(r_tx_o === s_data_i[i])
            else begin
                $error("Bit %d FAIL: expected %b, got %b", i, s_data_i[i], r_tx_o);
                $stop;
            end
            $display("Bit %d: %b", i, r_tx_o);
        end
        
        @(posedge s_clk_i iff dut.r_state == TX_STOP); // waiting for stop bit
        $display("Finished transmission of %h (%b) at time %0t", data, data, $time);
        
        @(posedge s_clk_i iff dut.r_state == TX_IDLE); // waiting for being idle
        $display("TX idle and ready");
    endtask
    
    uart_tx #(
        .CLK_FREQ(`CLK_FREQ_MHZ*1000000),
        .BAUD_RATE(`BAUD_RATE)
    ) dut (
        .s_clk_i(s_clk_i),
        .s_rst_n_i(s_rst_n_i),
        .s_send_i(s_send_i),
        .s_data_i(s_data_i),
        .r_tx_o(r_tx_o)
    );
    
    initial s_clk_i = 0;
    always #(`CLK_PERIOD/2) s_clk_i = ~s_clk_i;
    
    initial begin
        s_rst_n_i = 0;
        s_send_i = 0;
        s_data_i = 8'b0;
        
        #100; s_rst_n_i = 1;
        wait(r_tx_o === 1'b1);
        #900;
        
        send_byte(8'b11011001);
        //#`BAUD_PERIOD;
        send_byte(8'b01111010);
        #`BAUD_PERIOD;
        
        $display("PASS");
        $finish;
    end 

endmodule