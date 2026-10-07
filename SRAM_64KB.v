//============================================================
// Consolidated 64 KB SRAM
//   - Physical array : 1024 rows x 512 bits = 64 KB
//   - Logical view   : 16,384 words x 32 bits
//   - Single read/write port (32-bit)
//   - Synchronous write, synchronous read (1-cycle latency)
//============================================================
module sram_64kb #(
    parameter ADDR_WIDTH = 14,          // 2^14 = 16,384 words
    parameter DATA_WIDTH = 32,          // 4 bytes per word
    parameter DEPTH      = 16384        // 16,384 words = 64 KB
)(
    input  wire                    clk,
    input  wire                    cs,      // chip select (active high)
    input  wire                    we,      // 1 = write, 0 = read
    input  wire [ADDR_WIDTH-1:0]   addr,
    input  wire [DATA_WIDTH-1:0]   din,
    output reg  [DATA_WIDTH-1:0]   dout
);

    //----------------------------------------------------------
    // Storage: 16,384 words x 32 bits
    // (Equivalent to 1024 rows x 512 bits at the cell level)
    //----------------------------------------------------------
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    //----------------------------------------------------------
    // Write / Read logic
    //   - Write : on rising edge when cs=1, we=1
    //   - Read  : on rising edge when cs=1, we=0 (registered out)
    //----------------------------------------------------------
    always @(posedge clk) begin
        if (cs) begin
            if (we) begin
                mem[addr] <= din;       // write
            end
            else begin
                dout <= mem[addr];      // read
            end
        end
    end

endmodule