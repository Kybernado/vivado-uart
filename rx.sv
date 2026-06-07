`timescale 1ns/1ps

typedef enum logic [1:0] {
    RX_IDLE = 2'b00,
    RX_READY = 2'b01,
    RX_RECEIVING = 2'b10,
    RX_RECEIVED = 2'b11
} rx_state_t;

module uart_rx #(
    parameter CLK_FREQ = 12000000,
    parameter BAUD_RATE = 115200,
    parameter CLKS_PER_BIT = CLK_FREQ / BAUD_RATE
)(
    input logic s_clk_i,
    input logic s_rst_n_i,
    input logic s_rx_i,
    output logic [7:0] s_data_o,
    output logic r_data_valid_o 
);
    
    rx_state_t r_state; 
    logic [2:0] r_bit_count;
    logic [31:0] r_clk_count;
    
    always_ff @(posedge s_clk_i or negedge s_rst_n_i) begin
        if(!s_rst_n_i) begin
            s_data_o <= 8'b0;
            r_state <= RX_IDLE;
            r_clk_count <= 32'b0;
            r_bit_count <= 3'b0;
            r_data_valid_o <= 1'b0;
        end else begin
            if(r_state == RX_IDLE) begin
                if(s_rx_i == 1'b0) begin
                    r_state <= RX_READY;
                    r_clk_count <= CLKS_PER_BIT / 2;
                end
            end else begin 
                if(r_clk_count >= CLKS_PER_BIT - 1) begin
                    r_clk_count <= 32'b0;
                    
                    case(r_state)
                        RX_READY: begin
                            r_state <= RX_RECEIVING;
                            r_bit_count <= 3'b0;
                        end
                        
                        RX_RECEIVING: begin
                            s_data_o[r_bit_count] <= s_rx_i;
                            r_bit_count <= r_bit_count +1;
                            if(r_bit_count == 7) begin
                                r_state <= RX_RECEIVED;
                                r_data_valid_o <= 1'b1;
                            end
                        end
                        
                        RX_RECEIVED: begin
                            r_state <= RX_IDLE;
                            r_data_valid_o <= 1'b0;
                        end    
                    endcase
                end else begin
                    r_clk_count <= r_clk_count +1;
                end
            end
        end
    end

endmodule