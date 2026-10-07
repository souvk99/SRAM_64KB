`timescale 1ns/1ps

module tb_sram_64kb;

    //----------------------------------------------------------
    // Parameters
    //----------------------------------------------------------
    localparam ADDR_WIDTH = 14;
    localparam DATA_WIDTH = 32;

    //----------------------------------------------------------
    // DUT signals
    //----------------------------------------------------------
    reg                     clk;
    reg                     cs;
    reg                     we;
    reg  [ADDR_WIDTH-1:0]   addr;
    reg  [DATA_WIDTH-1:0]   din;
    wire [DATA_WIDTH-1:0]   dout;

    //----------------------------------------------------------
    // Bookkeeping for verification
    //----------------------------------------------------------
    integer i;
    reg [ADDR_WIDTH-1:0] wr_addr [0:7];
    reg [DATA_WIDTH-1:0] wr_data [0:7];
    reg [DATA_WIDTH-1:0] rd_data;
    integer errors;

    //----------------------------------------------------------
    // DUT instantiation
    //----------------------------------------------------------
    sram_64kb #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        .DEPTH      (16384)
    ) dut (
        .clk  (clk),
        .cs   (cs),
        .we   (we),
        .addr (addr),
        .din  (din),
        .dout (dout)
    );

    //----------------------------------------------------------
    // Clock generation : 10 ns period (100 MHz)
    //----------------------------------------------------------
    initial clk = 0;
    always #5 clk = ~clk;

    //----------------------------------------------------------
    // Test sequence
    //----------------------------------------------------------
    initial begin
        // Init
        cs   = 0;
        we   = 0;
        addr = 0;
        din  = 0;
        errors = 0;

        // ---------------------------------------------------
        // Phase 1 : WRITE to 8 locations using a for-loop
        //           (scattered addresses across the 16K words)
        // ---------------------------------------------------
        $display("================================================");
        $display(" Phase 1 : Writing 8 locations");
        $display("================================================");

        for (i = 0; i < 8; i = i + 1) begin
            wr_addr[i] = i * 14'd2000;            // 0, 2000, 4000, ...
            wr_data[i] = 32'hA5A5_0000 + i;       // unique pattern

            @(negedge clk);
            cs   = 1;
            we   = 1;
            addr = wr_addr[i];
            din  = wr_data[i];

            @(posedge clk);                       // write latched here
            $display("  WRITE : addr = %0d (0x%04h), data = 0x%08h",
                     addr, addr, din);

            @(negedge clk);
            we = 0;                               // deassert
            cs = 0;
        end

        // Small gap
        repeat (2) @(posedge clk);

        // ---------------------------------------------------
        // Phase 2 : READ back and verify
        // ---------------------------------------------------
        $display("================================================");
        $display(" Phase 2 : Reading back and verifying");
        $display("================================================");

        for (i = 0; i < 8; i = i + 1) begin
            @(negedge clk);
            cs   = 1;
            we   = 0;
            addr = wr_addr[i];

            @(posedge clk);                       // read issued
            @(posedge clk);                       // dout valid after 1 clk
            rd_data = dout;

            if (rd_data === wr_data[i]) begin
                $display("  PASS  : addr = %0d (0x%04h), read = 0x%08h",
                         wr_addr[i], wr_addr[i], rd_data);
            end
            else begin
                $display("  FAIL  : addr = %0d (0x%04h), read = 0x%08h, expected = 0x%08h",
                         wr_addr[i], wr_addr[i], rd_data, wr_data[i]);
                errors = errors + 1;
            end

            @(negedge clk);
            cs = 0;
        end

        // ---------------------------------------------------
        // Summary
        // ---------------------------------------------------
        $display("================================================");
        if (errors == 0)
            $display(" RESULT : ALL 8 LOCATIONS VERIFIED SUCCESSFULLY");
        else
            $display(" RESULT : %0d MISMATCH(ES) DETECTED", errors);
        $display("================================================");

        $finish;
    end

    //----------------------------------------------------------
    // Optional: waveform dump
    //----------------------------------------------------------
    initial begin
        $dumpfile("sram_64kb.vcd");
        $dumpvars(0, tb_sram_64kb);
    end

endmodule