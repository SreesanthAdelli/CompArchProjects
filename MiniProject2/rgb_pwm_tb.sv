`timescale 10ns/10ns
`include "rgb_pwm.sv"

module rgb_pwm_tb;

    logic clk = 0;
    logic RGB_R, RGB_G, RGB_B;

    // Instantiate top module
    top u0 (
        .clk    (clk),
        .RGB_R  (RGB_R),
        .RGB_G  (RGB_G),
        .RGB_B  (RGB_B)
    );

    // Dump waveform
    initial begin
        $dumpfile("rgb_pwm.vcd");
        $dumpvars(0, rgb_pwm_tb);

        #100000000   // 100000000 * 10ns = 1 s simulated
        $finish;
    end

    always begin
        #4
        clk = ~clk;
    end

endmodule

