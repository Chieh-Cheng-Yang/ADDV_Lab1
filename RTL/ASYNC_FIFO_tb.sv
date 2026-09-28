`timescale 1ns/1ns

module FIFO_tb#(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)
();
    logic W_clk, R_clk;
    logic W_rst_n, R_rst_n;
    logic W_en, R_en;
    logic [DATA_WIDTH - 1 : 0] W_data, R_data;
    logic full, empty;
    logic almost_empty;
    logic almost_full;


    FIFO_TOP #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) fifo_inst(.*);
    // FIFO_TOP #(
    //     .ADDR_WIDTH(ADDR_WIDTH),
    //     .DATA_WIDTH(DATA_WIDTH)
    // ) fifo_inst (
    //     .W_clk(W_clk),
    //     .R_clk(R_clk),
    //     .W_rst_n(W_rst_n),
    //     .R_rst_n(R_rst_n),
    //     .W_en(W_en),
    //     .R_en(R_en),
    //     .W_data(W_data),
    //     .full(full),
    //     .empty(empty),
    //     .R_data(R_data),
    //     .almost_empty(almost_empty),
    //     .almost_full(almost_full)
    // );

    // Clock Generator
    initial W_clk = 0;
    always #5 W_clk = ~W_clk;

    initial R_clk = 0;
    always #7 R_clk = ~R_clk;

    initial begin
	    $fsdbDumpfile("novas.fsdb");
	    $fsdbDumpvars(0, FIFO_tb);
	end	


    initial begin
        // ----------------------------------------------------------------------------------------------------------------------------------------

        // $display("========================");
        // $display("Test1 : Empty -> Full -> Empty -> Almost_full -> Almost_empty");
        // $display("========================");
        // // Reset the FIFO
        // reset_fifo();

        // // Check empty for begining
        // check_empty();
        // read_data();
        
        // // check empty works after reading empty FIFO
        // check_empty();
        
        // // Write data to FIFO
        // for (int i = 0; i < 16; i++) begin
        //     write_data(i);
        //     if (i == 13) check_full();
        // end
        // @(posedge W_clk);
        // @(posedge W_clk);
        // check_full();

        // write_data(8'hFF); // This write should not happen as FIFO is full
        // write_data(8'hDD); // This write should not happen as FIFO is full

        // @(posedge W_clk);
        // check_full();


        // for (int i = 0; i < 16; i++) begin
        //     read_data();
        //     if (i == 3 || i == 13) check_empty();
        // end
        // check_empty();
        // read_data();
        // read_data();

        // // @(posedge R_clk);
        // check_empty();

        // ----------------------------------------------------------------------------------------------------------------------------------------
        

        // Test 2: Check full and empty conditions
        // $display("========================");
        // $display("Test2 : Almost Full");
        // $display("========================");
        // reset_fifo();
        // for(int i=0;i<12;i++)
        //     write_data(i);

        // check_almost_full();
        // $display("========================");
        // $display("Test3 : Almost Empty");
        // $display("========================");
        
        // reset_fifo();

        // for(int i=0;i<16;i++)
        //     write_data(i);

        // for(int i=0;i<12;i++)
        //     read_data();

        // check_almost_empty();
        // read_data();
        // read_data();
        // read_data();
        // read_data();
        // read_data();

        // ----------------------------------------------------------------------------------------------------------------------------------------

        $display("========================");
        $display("Test2 : Simultaneous Read / Write");
        $display("========================");

        reset_fifo();

        // 先放一些資料進 FIFO，避免一開始一直 Read Empty
        for (int i = 0; i < 10; i++)
            write_data(i);

        fork

            begin : WRITE_THREAD
                for (int i = 6; i < 33; i++)
                    write_data(i);
            end

            // begin : READ_THREAD
            //     for (int i = 0; i < 20; i++)
            //         read_data();
            // end
            begin : READ_THREAD
                for (int i = 0; i < 40; i++)
                    read_data();
            end

        join


	

        $finish;
    end

    task check_almost_empty();
        begin
            @(posedge R_clk);

            if(almost_empty)
                $display("PASS for Almost Empty");
            else
                $display("FAIL for Almost Empty");
        end
    endtask

    task check_almost_full();
        begin
            @(posedge W_clk);

            if(almost_full)
                $display("PASS for Almost Full");
            else
                $display("FAIL for Almost Full");
        end
    endtask

    task check_full();
    begin
        @(posedge W_clk);  // Wait for one clock cycle

        if(full)
            $display("PASS for Full");
        else
            $display("not full yet ");
    end
    endtask

    task check_empty();
        begin
            @(posedge R_clk);
            if (empty)
                $display("PASS for Empty");
            else
                $display("not empty yet");
        end
    endtask


    // initial begin
    //     #1000;
    //     $display("Simulation Time Expired");
    //     $finish;
    // end

    // Task for writing data
    // -----------------------------------------------
    // W_en edge write_data   這裡不加automatic的話 第一個會是0  除此之外  還要用data_copy  不然strobe會印出clock edge後的i  而不是原本的輸入
    // 沒有 automatic 的 task，是 static task。
    // 也就是：
    // 所有呼叫都共用同一份變數。

    task automatic write_data(input [DATA_WIDTH - 1: 0] data); //建立一個叫做Write data的task 有一個輸入叫做data  
        logic [7:0] data_copy;
    begin
        // $display("[%0t]", $time);
        data_copy = data;
        @(posedge W_clk);
        W_en = 1;
        W_data = data;
        // if (full)
        //     $strobe("!!![%0t] WRITE %h : BLOCKED (FIFO FULL) | W_Count=%0d | Wptr_next=%0d | Rptr_sync=%0d ",
        //             $time, data,
        //             fifo_inst.Write_ptr_inst.W_fifo_count,
        //             fifo_inst.Write_ptr_inst.W_ptr_bin_next,
        //             fifo_inst.Write_ptr_inst.sync_r2w_r_ptr_bin,);
        // else
        //     $strobe("[%0t] WRITE %h : Accepted | Wptr_next=%0d | Rptr_sync=%0d | W_Count=%0d | almost_Full=%b | AlmostFull=%b",
        //  $time,
        //  data,
        //  fifo_inst.Write_ptr_inst.W_ptr_bin_next,
        //  fifo_inst.Write_ptr_inst.sync_r2w_r_ptr_bin,
        //  fifo_inst.Write_ptr_inst.W_fifo_count,
        // //  full,
        // fifo_inst.Write_ptr_inst.full_next,
        //  almost_full);


        @(posedge W_clk);
        W_en = 0;
        // check_full();


        if (full)
            // $strobe("!!![%0t] WRITE %h : BLOCKED (FIFO FULL) | W_Count=%0d | Wptr=%0d | Rptr_sync=%0d ",
            $display("!!![%0t] WRITE %h : BLOCKED (FIFO FULL) | W_Count=%0d | Wptr=%0d | Rptr_sync=%0d ",
                    $time, data_copy,
                    fifo_inst.Write_ptr_inst.W_fifo_count,
                    fifo_inst.Write_ptr_inst.W_ptr_bin,
                    fifo_inst.Write_ptr_inst.sync_r2w_r_ptr_bin,);
        else
            // $strobe("[%0t] WRITE %h : Accepted | W_Count=%0d | Rptr_sync=%0d | Wptr=%0d | AlmostFull=%b",
            $display("[%0t] WRITE %h : Accepted | W_Count=%0d | Rptr_sync=%0d | Wptr=%0d | AlmostFull=%b",
            
         $time,
         data_copy,
         fifo_inst.Write_ptr_inst.W_fifo_count,
         fifo_inst.Write_ptr_inst.sync_r2w_r_ptr_bin,
         fifo_inst.Write_ptr_inst.W_ptr_bin,
        //  full,
         almost_full);
    end
    endtask
    // -----------------------------------------------

    // write mem edge write data
    // task write_data(input [DATA_WIDTH - 1: 0] data); //建立一個叫做Write data的task 有一個輸入叫做data
    // bit full_before;
    // full_before = full;
    // begin
    //     @(posedge W_clk);
    //     W_en = 1;
    //     W_data = data;

    //     @(posedge W_clk);
    //     // #1;
    //     if (full_before)
    //         $strobe("[%0t] WRITE %h : BLOCKED (FIFO FULL) | Count=%0d",
    //                 $time,
    //                 data,
    //                 fifo_inst.Write_ptr_inst.W_fifo_count);
    //     else
    //         $strobe("[%0t] WRITE %h : SUCCESS | Count=%0d | Full=%b | AlmostFull=%b",
    //                 $time,
    //                 data,
    //                 fifo_inst.Write_ptr_inst.W_fifo_count,
    //                 full,
    //                 almost_full);
    //     W_en = 0;
    // end
    // endtask



    task reset_fifo();
    begin
        W_rst_n = 0;
        R_rst_n = 0;
        W_en = 0;
        R_en = 0;
        W_data = '0;
        
        #20;
        W_rst_n = 1;
        R_rst_n = 1;
        $display("[%0t] Reset released", $time);
        repeat(2) @(posedge W_clk);
        repeat(2) @(posedge R_clk);
    end
    endtask

    task read_data();
     
    bit empty_before;
    begin
        @(posedge R_clk);
        R_en = 1;
        empty_before = empty;
        // if (empty)
        //     $strobe("!!![%0t] READ : BLOCKED (FIFO EMPTY) | R_Count=%0d | Rptr=%0d | Wptr_sync=%0d",
        //             $time,
        //             fifo_inst.Read_ptr_inst.R_fifo_count,
        //         fifo_inst.Read_ptr_inst.R_ptr_bin,
        //         fifo_inst.Read_ptr_inst.sync_w2r_w_ptr_bin);
        // else
        //     $strobe("[%0t] READ %h : READ REQUEST ACCEPTED | Rptr=%0d | Wptr_sync=%0d | R_Count=%0d | Empty_next=%b | AlmostEmpty=%b",
        //  $time,
        //  R_data,
        //  fifo_inst.Read_ptr_inst.R_ptr_bin,
        //  fifo_inst.Read_ptr_inst.sync_w2r_w_ptr_bin,
        //  fifo_inst.Read_ptr_inst.R_fifo_count,
        // //  empty,
        // fifo_inst.Read_ptr_inst.empty_next,
        //  almost_empty);

        @(posedge R_clk);
        R_en = 0;
        // check_empty();



        if (empty_before)
            // $strobe("!!![%0t] READ : BLOCKED (FIFO EMPTY) | R_Count=%0d | Rptr=%0d | Wptr_sync=%0d",
            $display("!!![%0t] READ : BLOCKED (FIFO EMPTY) | R_Count=%0d | Rptr=%0d | Wptr_sync=%0d",
                    $time,
                    fifo_inst.Read_ptr_inst.R_fifo_count,
                fifo_inst.Read_ptr_inst.R_ptr_bin,
                fifo_inst.Read_ptr_inst.sync_w2r_w_ptr_bin);
        else
            // $strobe("[%0t] READ %h : ACCEPTED | R_Count=%0d | Wptr_sync=%0d | Rptr=%0d | AlmostEmpty=%b",
            $display("[%0t] READ %h : ACCEPTED | R_Count=%0d | Wptr_sync=%0d | Rptr=%0d | AlmostEmpty=%b",
         $time,
         R_data,
         fifo_inst.Read_ptr_inst.R_fifo_count,
         fifo_inst.Read_ptr_inst.sync_w2r_w_ptr_bin,
         fifo_inst.Read_ptr_inst.R_ptr_bin,
        //  empty,
        // fifo_inst.Read_ptr_inst.empty,
         almost_empty);
    end
    endtask

    // always @(posedge W_clk) begin
    //     $display("[%0t] WCLK | Wptr=%b | Rptr_sync=%b | Full=%b | Waddr=%h",
    //             $time,
    //             fifo_inst.Write_ptr_inst.W_ptr_bin,
    //             fifo_inst.sync_r2w_r_ptr,
    //             full,
    //             fifo_inst.W_addr);
    // end

    // always @(posedge R_clk) begin
    //     $display("[%0t] RCLK | Rptr=%b | Wptr_sync=%b | Empty=%b | Raddr=%h",
    //             $time,
    //             fifo_inst.Read_ptr_inst.R_ptr_bin,
    //             fifo_inst.sync_w2r_w_ptr,
    //             empty,
    //             fifo_inst.R_addr);
    // end


    // task read_data_check(input [7:0] expected);

    // begin

    //     @(posedge R_clk);

    //     R_en = 1;

    //     @(posedge R_clk);

    //     if(R_data == expected)
    //         $display("PASS Read %h", expected);
    //     else
    //         $error("FAIL Expect %h Got %h",
    //                 expected,R_data);

    //     R_en = 0;

    // end

    // endtask


endmodule
