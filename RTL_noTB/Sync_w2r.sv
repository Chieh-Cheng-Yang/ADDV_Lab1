`timescale 1ns/1ps
module Sync_w2r #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input logic R_clk, R_rst_n,
    input logic [ADDR_WIDTH:0] W_ptr_gray,
    output logic [ADDR_WIDTH:0] sync_w2r_w_ptr
);

    logic [ADDR_WIDTH:0] sync_w2r_w_ptr_ff1;
    
    always_ff @(posedge R_clk or negedge R_rst_n) begin
        if (!R_rst_n) begin
            sync_w2r_w_ptr_ff1 <= '0;
            sync_w2r_w_ptr <= '0;
        end else begin
            sync_w2r_w_ptr_ff1 <= W_ptr_gray;
            sync_w2r_w_ptr <= sync_w2r_w_ptr_ff1;
        end
    end


endmodule
