// Blink LED through the HSV circle, such that it flashes red every one second,
// and moves 60* through circle each time.


module top(
    input logic clk,
    input logic SW,
    output logic RGB_B,
    output logic RGB_G,
    output logic RGB_R
);    

    logic [20:0] count;
    parameter interval = 2000000; // 2 million clock cycles interval 
    // Counter and Color Step Logic 
    
    logic [2:0] rgb_step; // Number of rgb steps. 6 total.
        
    always_ff @(posedge clk) begin
        if (!SW) begin
            count <= 0;
            rgb_step <= 0;
        end else if (count == interval - 1) begin
            count <= 0;
            rgb_step <= (rgb_step == 5) ? 0 : rgb_step + 1;
        end else 
            count <= count + 1;
    end

    // Map rgb_step to RGB outputs
    always_comb begin
        case (rgb_step)
            3'd0: {RGB_R, RGB_G, RGB_B} = 3'b100; // red
            3'd1: {RGB_R, RGB_G, RGB_B} = 3'b110; // yellow
            3'd2: {RGB_R, RGB_G, RGB_B} = 3'b010; // green
            3'd3: {RGB_R, RGB_G, RGB_B} = 3'b011; // cyan
            3'd4: {RGB_R, RGB_G, RGB_B} = 3'b001; // blue
            3'd5: {RGB_R, RGB_G, RGB_B} = 3'b101; // magenta
            default: {RGB_R, RGB_G, RGB_B} = 3'b000;
        endcase
    end
endmodule
    

    


    
