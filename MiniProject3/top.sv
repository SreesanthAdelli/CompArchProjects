`include "ws2812b.sv"
`include "controller.sv"
`include "game_of_life.sv"

module top (
    input  logic clk,
    output logic _48b
);

    // --- Signals ---
    logic [5:0] pixel;
    logic load_sreg, transmit_pixel, shift;
    logic ws_out;

    logic [7:0] red_data, green_data, blue_data;
    logic [23:0] shift_reg;

    // --- 1 Hz tick ---
    logic [23:0] div_counter;
    logic tick;
    always_ff @(posedge clk) begin
        if (div_counter == 24'd11_999_999) begin // 12 MHz / 1 Hz
            div_counter <= 0;
            tick <= 1'b1;
        end else begin
            div_counter <= div_counter + 1;
            tick <= 1'b0;
        end
    end

    // --- 8x8 grids for each color ---
    logic [63:0] red_grid, green_grid, blue_grid;

    // --- 8x8 grid gliders (3 different starting points) ---
    localparam [63:0] RED_INIT   = 64'b11100000_00000000_00001000_00000000_00000000_00000000_00000000_00000000; // glider 1
    localparam [63:0] GREEN_INIT = 64'b00000000_00011100_00000000_00000000_00000000_00000000_00000000_00000000; // glider 2
    localparam [63:0] BLUE_INIT  = 64'b00000000_00000000_00000111_00000000_00000000_00000000_00000000_00000000; // glider 3


    // --- Game of Life instances ---
    game_of_life #(.INIT_GRID(RED_INIT))   u_red_gol   (.clk(clk), .tick(tick), .grid_out(red_grid));
    game_of_life #(.INIT_GRID(GREEN_INIT)) u_green_gol (.clk(clk), .tick(tick), .grid_out(green_grid));
    game_of_life #(.INIT_GRID(BLUE_INIT))  u_blue_gol  (.clk(clk), .tick(tick), .grid_out(blue_grid));

    // --- Convert 1-bit grid to 8-bit channel for WS2812B ---
    always_comb begin
        red_data   = {8{red_grid[pixel]}};
        green_data = {8{green_grid[pixel]}};
        blue_data  = {8{blue_grid[pixel]}};
    end

    // --- Controller ---
    controller u_ctrl (
        .clk(clk),
        .load_sreg(load_sreg),
        .transmit_pixel(transmit_pixel),
        .pixel(pixel)
    );

    // --- WS2812B driver ---
    ws2812b u_ws (
        .clk(clk),
        .serial_in(shift_reg[23]),
        .transmit(transmit_pixel),
        .ws2812b_out(ws_out),
        .shift(shift)
    );

    // --- Shift register logic ---
    always_ff @(posedge clk) begin
        if (load_sreg)
            shift_reg <= {green_data, red_data, blue_data}; // RGB format
        else if (shift)
            shift_reg <= {shift_reg[22:0], 1'b0};
    end

    assign _48b = ws_out;

endmodule
