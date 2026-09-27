`timescale 1ns/1ns
module Read_ptr #(
	parameter ADDR_WIDTH = 4,			
	parameter DATA_WIDTH = 8				
)(
    input logic R_clk, R_rst_n, R_en,
    input logic [ADDR_WIDTH:0] sync_w2r_w_ptr,
    output logic [ADDR_WIDTH:0] R_ptr_gray,
    output logic [ADDR_WIDTH - 1:0] R_addr,
    output logic empty,
    output logic almost_empty
);

    localparam FIFO_DEPTH = 1 << ADDR_WIDTH;
    // comb
    logic empty_next;
    // logic almost_empty_next;
    logic [ADDR_WIDTH:0] R_ptr_gray_next, R_ptr_bin_next;
    logic [ADDR_WIDTH:0] sync_w2r_w_ptr_bin;
    logic [ADDR_WIDTH:0] R_fifo_count;   // fifo_count 紀錄目前 FIFO 內有多少筆資料
// 範圍是 0 ~ FIFO_DEPTH (0 ~ 2^ADDR_WIDTH)
// 因此需要 ADDR_WIDTH+1 bits 才能表示
    // FF
    logic [ADDR_WIDTH:0] R_ptr_bin;
    // logic [ADDR_WIDTH:0] R_fifo_count;   // fifo_count 紀錄目前 FIFO 內有多少筆資料
    
    assign R_addr = R_ptr_bin[ADDR_WIDTH - 1:0];

    always_comb begin
        R_ptr_bin_next = R_ptr_bin + (R_en && !empty);
        R_ptr_gray_next = (R_ptr_bin_next >> 1) ^ R_ptr_bin_next;
        empty_next = (sync_w2r_w_ptr == R_ptr_gray_next);
        sync_w2r_w_ptr_bin = gray2bin(sync_w2r_w_ptr);
        // R_fifo_count = sync_w2r_w_ptr_bin - R_ptr_bin_next;        //這裡是用R_ptr_bin_next而不是R_ptr_bin，因為是要判斷這次讀完之後會不會almost empty.
        R_fifo_count = sync_w2r_w_ptr_bin - R_ptr_bin;
        almost_empty = (R_fifo_count <=  (FIFO_DEPTH >> 2));  // fifo_count <= FIFO_DEPTH/4
    end                                                         // 任意除法 (/7、/10、/13) 在硬體通常成本很高。
                                                                // 除以 2 的冪次 (/2、/4、/8...) 幾乎都可以用位移完成。
    
    
    always_ff @(posedge R_clk or negedge R_rst_n) begin
        if (!R_rst_n) begin
            empty <= 1'b1;
            // almost_empty <= 1'b1;
            R_ptr_bin <= '0;
            R_ptr_gray <= '0;
            // R_fifo_count <= '0;
        end else begin
            R_ptr_bin <= R_ptr_bin_next;
            R_ptr_gray <= R_ptr_gray_next;
            empty <= empty_next;
            // almost_empty <= almost_empty_next;   // Memory 第 5 筆寫進去後，不是 almost_empty 馬上變，而是要等 Write Pointer 經過 Synchronizer，  
            // R_fifo_count <= R_fifo_count_next;    // 再由 Read_ptr 的 FF 更新 almost_empty。因此在目前這個 RTL 架構下，波形通常會看到約 3 個 R_clk 的延遲                                            
                            // 這個 fifo_count 是在 Read Domain 的，會被用來判斷 almost_empty。
        end                                      
    end


    // 用automatic 才可以建立個別的變數
    // 沒有automatic的話，function裡面的變數會被所有的instance共用，會造成錯誤
    function automatic [ADDR_WIDTH:0] gray2bin(      //這個gray2bin就是這個function的回傳值   // return gray2bin; func的名字就是回傳variable的名字
        input [ADDR_WIDTH:0] gray
    );  // gray是輸入
        integer i;

        begin
            gray2bin[ADDR_WIDTH] = gray[ADDR_WIDTH];
            for (i = ADDR_WIDTH - 1; i >= 0; i = i - 1) begin
                gray2bin[i] = gray2bin[i + 1] ^ gray[i];
            end
        end
    endfunction

    // Binary → Gray
    // Gray = Binary ^ (Binary >> 1)
    // Gray[i] = Binary[i+1] ^ Binary[i]
    // Gray[MSB] = Binary[MSB]
    // -----------------------
    //          B4 B3 B2 B1 B0
    // XOR      0  B4 B3 B2 B1
    // ------------------------
    // Gray     G4 G3 G2 G1 G0


    // Gray → Binary
    // Binary[MSB] = Gray[MSB]
    // Binary[i] = Binary[i+1] ^ Gray[i]

    // G4 G3 G2 G1 G0

    // B4 = G4
    // B3 = G4 ^ G3
    // B2 = G4 ^ G3 ^ G2
    // B1 = G4 ^ G3 ^ G2 ^ G1
    // B0 = G4 ^ G3 ^ G2 ^ G1 ^ G0
    
endmodule
