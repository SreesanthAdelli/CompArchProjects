`timescale 10ns/10ns
`include "top.sv"

module test_bench;

    logic clk = 0;
    logic _48b;

    // Instantiate top
    top u0 (
        .clk(clk),
        ._48b(_48b)
    );

    // VCD dump
    initial begin
        $dumpfile("test_bench.vcd");
        $dumpvars(0, test_bench);
        #500_000_000   // 5 seconds.
        $finish;
    end

    // Clock generation: 80 ns period = 12.5 MHz
    always begin
        #4 clk = ~clk;
    end

endmodule
