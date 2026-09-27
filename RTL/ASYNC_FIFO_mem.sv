`timescale 1ns/1ns

module Mem #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    mem_if.mem mem_bus
);

localparam FIFO_DEPTH = 1 << ADDR_WIDTH;

logic [DATA_WIDTH-1:0] mem [FIFO_DEPTH-1:0];

always_ff @(posedge mem_bus.W_clk) begin
    if (mem_bus.W_en) begin
        mem[mem_bus.W_addr] <= mem_bus.W_data;
    end
end

always_comb begin
    mem_bus.R_data = mem[mem_bus.R_addr];
end



endmodule
