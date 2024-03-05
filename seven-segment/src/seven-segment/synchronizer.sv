`timescale 1ns / 1ps

module synchronizer #(
    parameter CHAIN_LENGTH = 2
) (
    input logic clk_i,
    input logic clk_en_i,
    input logic signal_i,
    output logic signal_o
);

logic [CHAIN_LENGTH-1:0] chain;

assign signal_o = chain[CHAIN_LENGTH-1];

always_ff @(posedge clk_i) begin
    if (clk_en_i) for (int i = 0; i < CHAIN_LENGTH; i++) chain[i] <= i == '0 ? signal_i : chain[i-1];
end
endmodule
