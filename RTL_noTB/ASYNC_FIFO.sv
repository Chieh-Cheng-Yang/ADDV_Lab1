`timescale 1ns/1ns
module FIFO_TOP #(
	parameter ADDR_WIDTH = 4,			
	parameter DATA_WIDTH = 8				
)(
	input  logic W_clk, R_clk,
	input  logic W_rst_n, R_rst_n,
	input  logic W_en, R_en,
	input  logic [DATA_WIDTH - 1 : 0] W_data,

	output logic full, empty,
	output logic [DATA_WIDTH - 1 : 0] R_data,
    output logic almost_empty,
    output logic almost_full
);

logic [ADDR_WIDTH:0] W_ptr_gray, R_ptr_gray;
logic [ADDR_WIDTH:0] sync_r2w_r_ptr, sync_w2r_w_ptr;
logic [ADDR_WIDTH - 1:0] W_addr, R_addr;

// Read_ptr Read_ptr_inst(.*);
// Mem Mem_inst(.*);
// Write_ptr Write_ptr_inst(.*);
// Sync_r2w Sync_r2w_inst(.*);
// Sync_w2r Sync_w2r_inst(.*);


Read_ptr Read_ptr_inst(
    .R_clk(R_clk),
    .R_rst_n(R_rst_n),
    .R_en(R_en),
    .sync_w2r_w_ptr(sync_w2r_w_ptr),
    .R_ptr_gray(R_ptr_gray),
    .R_addr(R_addr),
    .empty(empty),
    .almost_empty(almost_empty)
);

mem_if #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) mem_bus();

assign mem_bus.W_clk  = W_clk;
assign mem_bus.W_en   = W_en;
assign mem_bus.W_addr = W_addr;
assign mem_bus.R_addr = R_addr;
assign mem_bus.W_data = W_data;

assign R_data = mem_bus.R_data;

Mem #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) Mem_inst (
    .mem_bus(mem_bus)
);

Write_ptr Write_ptr_inst(
    .W_clk(W_clk),
    .W_rst_n(W_rst_n),
    .W_en(W_en),
    .sync_r2w_r_ptr(sync_r2w_r_ptr),
    .W_ptr_gray(W_ptr_gray),
    .W_addr(W_addr),
    .full(full),
    .almost_full(almost_full)
);

Sync_r2w Sync_r2w_inst(
    .W_clk(W_clk),
    .W_rst_n(W_rst_n),
    .R_ptr_gray(R_ptr_gray),
    .sync_r2w_r_ptr(sync_r2w_r_ptr)
);

Sync_w2r Sync_w2r_inst(
    .R_clk(R_clk),
    .R_rst_n(R_rst_n),
    .W_ptr_gray(W_ptr_gray),
    .sync_w2r_w_ptr(sync_w2r_w_ptr)
);

endmodule
