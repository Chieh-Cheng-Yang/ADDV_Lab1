`timescale 1ns/1ns
module Write_ptr #(
	parameter ADDR_WIDTH = 4,			
	parameter DATA_WIDTH = 8				
)(
    input logic W_clk, W_en, W_rst_n,
    input logic [ADDR_WIDTH:0] sync_r2w_r_ptr,
    output logic [ADDR_WIDTH:0] W_ptr_gray,
    output logic [ADDR_WIDTH - 1:0] W_addr,
    output logic full,
    output logic almost_full
);
    localparam FIFO_DEPTH = 1 << ADDR_WIDTH;
    // FF
    logic [ADDR_WIDTH:0] W_ptr_bin;
    // logic [ADDR_WIDTH:0] W_fifo_count;
    // comb 
    logic [ADDR_WIDTH:0] W_ptr_bin_next, W_ptr_gray_next;
    logic [ADDR_WIDTH:0] sync_r2w_r_ptr_bin;
    logic full_next;
    // logic [ADDR_WIDTH:0] W_fifo_count_next;
    logic [ADDR_WIDTH:0] W_fifo_count; // Read 和write 都有fifo count，只是是在不同的domain，這裡是用來判斷almost full的
    // logic almost_full_next;

    always_ff @(posedge W_clk or negedge W_rst_n) begin
        if (!W_rst_n) begin 
            full <= 1'b0;
            W_ptr_bin <= '0;
            W_ptr_gray <= '0;
            // almost_full <= 1'b0;
            // W_fifo_count <= '0;
        end else begin
            W_ptr_bin <= W_ptr_bin_next;
            W_ptr_gray <= W_ptr_gray_next;
            full <= full_next;
            // almost_full <= almost_full_next;
            // W_fifo_count <= W_fifo_count_next;
        end
    end

    assign W_addr = W_ptr_bin[ADDR_WIDTH - 1:0];

    always_comb begin
        W_ptr_bin_next = W_ptr_bin + (W_en && !full);
        W_ptr_gray_next = ((W_ptr_bin_next >> 1) ^ W_ptr_bin_next);
        full_next = (W_ptr_gray_next[ADDR_WIDTH] != sync_r2w_r_ptr[ADDR_WIDTH]) &&
                    (W_ptr_gray_next[ADDR_WIDTH-1] != sync_r2w_r_ptr[ADDR_WIDTH-1]) &&
                    (W_ptr_gray_next[ADDR_WIDTH-2:0] == sync_r2w_r_ptr[ADDR_WIDTH-2:0]);
        sync_r2w_r_ptr_bin = gray2bin(sync_r2w_r_ptr);
        // W_fifo_count = W_ptr_bin_next - sync_r2w_r_ptr_bin; // 補數的減法會自動處理overflow的情況
        W_fifo_count = W_ptr_bin - sync_r2w_r_ptr_bin;
        almost_full = (W_fifo_count >= (FIFO_DEPTH - (FIFO_DEPTH >> 2)));
    end


    function automatic [ADDR_WIDTH:0] gray2bin(
        input [ADDR_WIDTH:0] gray
    );
        integer i;

        begin
            gray2bin[ADDR_WIDTH] = gray[ADDR_WIDTH];
            for (i = ADDR_WIDTH - 1; i >= 0; i = i - 1) begin
                gray2bin[i] = gray2bin[i + 1] ^ gray[i];
            end
        
        end
    endfunction




endmodule
