`timescale 1ns/1ps
module Sync_r2w #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input logic W_clk, W_rst_n,
    input logic [ADDR_WIDTH:0] R_ptr_gray,
    output logic [ADDR_WIDTH:0] sync_r2w_r_ptr
);

    logic [ADDR_WIDTH:0] sync_r2w_r_ptr_ff1;
    
    always_ff @(posedge W_clk or negedge W_rst_n) begin
        if (!W_rst_n) begin
            sync_r2w_r_ptr_ff1 <= '0;
            sync_r2w_r_ptr <= '0;
        end else begin
            sync_r2w_r_ptr_ff1 <= R_ptr_gray;
            sync_r2w_r_ptr <= sync_r2w_r_ptr_ff1;
        end
    end


endmodule
