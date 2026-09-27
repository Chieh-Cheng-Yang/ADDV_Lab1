`timescale 1ns/1ns
interface mem_if #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
);

    logic W_clk;
    logic W_en;

    logic [ADDR_WIDTH-1:0] W_addr;
    logic [ADDR_WIDTH-1:0] R_addr;

    logic [DATA_WIDTH-1:0] W_data;
    logic [DATA_WIDTH-1:0] R_data;

    modport mem (
        input  W_clk, W_en, W_addr, R_addr, W_data,
        output R_data
    );

    modport ctrl (
        output W_clk, W_en, W_addr, R_addr, W_data,
        input  R_data
    );

endinterface
