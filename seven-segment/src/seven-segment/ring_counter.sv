`timescale 1ns / 1ps

module ring_counter #(
    parameter NUM_BITS = 4,
    parameter INIT_PATTERN = 4'b1110
) (
    input logic reset_i,
    input logic clk_i,
    input logic clk_en_i,
    output logic [NUM_BITS-1:0] val_o
);

always_ff @(posedge clk_i, posedge reset_i) begin
    if (reset_i) val_o <= INIT_PATTERN;
    else if (clk_en_i) for (int i = 0; i < NUM_BITS; i++) val_o[i] <= i == 0 ? val_o[NUM_BITS-1] : val_o[i-1];
end
endmodule
