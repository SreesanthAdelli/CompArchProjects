module game_of_life #(
    parameter [63:0] INIT_GRID = 64'hFFFF_FFFF_FFFF_FFFF
)(
    input  logic clk,
    input  logic tick,         // slow update tick
    output logic [63:0] grid_out
);

    logic [63:0] grid;
    logic [63:0] next_grid;

    // initialize
    initial grid = INIT_GRID;

    // --- Precompute neighbor shifts ---
    logic [63:0] north, south, east, west;
    logic [63:0] ne, nw, se, sw;

    // sum neighbors (count of live neighbors)
    logic [3:0] neighbors [63:0];
    integer i;

    always_comb begin
        // wrap-around shifts
        north = {grid[7:0], grid[63:8]};      // shift up
        south = {grid[55:0], grid[63:56]};    // shift down
        east  = {grid[0], grid[63:1]};        // shift right
        west  = {grid[62:0], grid[63]};       // shift left

        ne = {north[0], north[63:1]};         // north-east
        nw = {north[63:1], north[0]};         // north-west
        se = {south[0], south[63:1]};         // south-east
        sw = {south[63:1], south[0]};         // south-west

        for (i = 0; i < 64; i = i + 1) begin
            neighbors[i] = north[i] + south[i] + east[i] + west[i] +
                           ne[i] + nw[i] + se[i] + sw[i];
        end

        // apply Game of Life rules
        for (i = 0; i < 64; i = i + 1) begin
            if (grid[i])
                next_grid[i] = (neighbors[i] == 2 || neighbors[i] == 3);
            else
                next_grid[i] = (neighbors[i] == 3);
        end
    end

    always_ff @(posedge clk) begin
        if (tick)
            grid <= next_grid;
    end

    assign grid_out = grid;

endmodule
