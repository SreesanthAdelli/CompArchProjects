// PWM Generator
module pwm (
    input  logic        clk,
    input  logic [7:0]  duty_cycle,  // 8-bit 0-255
    output logic        pwm_out      // active-low output
);
    logic [7:0] counter;
    always_ff @(posedge clk) begin
        counter <= counter + 1;
        pwm_out <= ~(counter < duty_cycle); // invert for active-low LED
    end
endmodule

// RGB Controller using tick splitting
module rgb_controller_tick (
    input  logic clk,       // 12 MHz board clock
    output logic [7:0] r,   // Duty cycle to be used as input for pwm module
    output logic [7:0] g,
    output logic [7:0] b
);
    // FSM states, in enum where RED_TO_YELLOW is 0 and MAGENTA_TO_RED is
    // 5 (decimal).
    typedef enum logic [2:0] {
        RED_TO_YELLOW,
        YELLOW_TO_GREEN,
        GREEN_TO_CYAN,
        CYAN_TO_BLUE,
        BLUE_TO_MAGENTA,
        MAGENTA_TO_RED
    } state_t;

    state_t state = RED_TO_YELLOW;

    // We need to increase progress once every 7812.5 ticks. Obviously we
    // can't directly do that, so we will instead increment progress after
    // 7812 ticks once, then 7813, in a cycle using a toggle bit.

    // Progress and tick counters
    reg [7:0] progress = 0;
    reg [12:0] tick_count = 0; // enough for 7813 max
    reg toggle = 0;             // add extra tick every other step

    integer STEP_TICKS = 7812; // base ticks per step

    always_ff @(posedge clk) begin
        if (tick_count == STEP_TICKS + toggle) begin
            tick_count <= 0;
            progress <= progress + 1;
            toggle <= ~toggle; // flip to add 1 extra tick every other step

            if (progress == 8'd255) begin
                progress <= 0;
                // move to next segment
                case (state)
                    RED_TO_YELLOW:    state <= YELLOW_TO_GREEN;
                    YELLOW_TO_GREEN:  state <= GREEN_TO_CYAN;
                    GREEN_TO_CYAN:    state <= CYAN_TO_BLUE;
                    CYAN_TO_BLUE:     state <= BLUE_TO_MAGENTA;
                    BLUE_TO_MAGENTA:  state <= MAGENTA_TO_RED;
                    MAGENTA_TO_RED:   state <= RED_TO_YELLOW;
                endcase
            end
        end else begin
            tick_count <= tick_count + 1;
        end
    end

    // Map progress to RGB
    always_comb begin
        r = 0;
        g = 0;
        b = 0;
        case (state)
            RED_TO_YELLOW: begin
                r = 8'd255;
                g = progress;
                b = 8'd0;
            end
            YELLOW_TO_GREEN: begin
                r = 8'd255 - progress;
                g = 8'd255;
                b = 8'd0;
            end
            GREEN_TO_CYAN: begin
                r = 8'd0;
                g = 8'd255;
                b = progress;
            end
            CYAN_TO_BLUE: begin
                r = 8'd0;
                g = 8'd255 - progress;
                b = 8'd255;
            end
            BLUE_TO_MAGENTA: begin
                r = progress;
                g = 8'd0;
                b = 8'd255;
            end
            MAGENTA_TO_RED: begin
                r = 8'd255;
                g = 8'd0;
                b = 8'd255 - progress;
            end
        endcase
    end
endmodule

// Top Module
module top (
    input  logic clk,      // 12 MHz board clock
    output logic RGB_R,    // active-low
    output logic RGB_G,    // active-low
    output logic RGB_B     // active-low
);
    logic [7:0] r_duty, g_duty, b_duty;

    // RGB controller module, defined above
    rgb_controller_tick rgb_inst(
        .clk(clk),
        .r(r_duty),
        .g(g_duty),
        .b(b_duty)
    );

    // PWM outputs
    pwm pwm_r(.clk(clk), .duty_cycle(r_duty), .pwm_out(RGB_R));
    pwm pwm_g(.clk(clk), .duty_cycle(g_duty), .pwm_out(RGB_G));
    pwm pwm_b(.clk(clk), .duty_cycle(b_duty), .pwm_out(RGB_B));
endmodule

