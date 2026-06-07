`timescale 1ns/1ps

typedef enum logic [1:0] {
	TX_IDLE = 2'b00,
	TX_START = 2'b01,
	TX_TRANSMITTING = 2'b10,
	TX_STOP = 2'b11
} tx_state_t;

module uart_tx #(
    parameter CLK_FREQ = 12000000,
    parameter BAUD_RATE = 115200,
    parameter CLKS_PER_BIT = CLK_FREQ / BAUD_RATE
)(
	input logic s_clk_i,
	input logic s_rst_n_i,
	input logic s_send_i,
	input logic [7:0] s_data_i,
	output logic r_tx_o
);

	tx_state_t r_state;
	logic [2:0] r_bit_count;
	
	logic [31:0] r_clk_count;
    
    always_ff @(posedge s_clk_i or negedge s_rst_n_i) begin
        if(!s_rst_n_i) begin
			r_state <= TX_IDLE;
			r_tx_o <= 1'b1;
			r_bit_count <= 3'b0;
			r_clk_count <= 32'b0;
		end else begin
		    if(r_state == TX_IDLE) begin
                r_tx_o <= 1'b1;
                if(s_send_i) begin
                    r_state <= TX_START;
                    r_clk_count <= 32'b0;
                end
            end else begin
                if(r_clk_count >= CLKS_PER_BIT - 1) begin
                  r_clk_count <= 32'b0;
                  case(r_state)
                        TX_START: begin
                            r_tx_o <= 1'b0;
                            r_bit_count <= 3'b0;
                            r_state <= TX_TRANSMITTING;
                        end
                    
                        TX_TRANSMITTING: begin
                            r_tx_o <= s_data_i[r_bit_count];
                            r_bit_count <= r_bit_count + 1;
                            if(r_bit_count == 3'd7) begin
                                r_state <= TX_STOP;
                            end
                        end
                    
                        TX_STOP: begin
                            r_tx_o <= 1'b1;
                            r_state <= TX_IDLE;
                        end
                    
                    endcase
                end else begin
                  r_clk_count <= r_clk_count + 1;
                end
		    end 
		end
    end
    
endmodule