module synchronizer #(
    parameter CHAIN_LENGTH = 2
) (
    input logic reset_i,
    input logic clk_i,
    input logic signal_i,
    output logic signal_o
);

logic [CHAIN_LENGTH-1:0] chain;

assign signal_o = chain[CHAIN_LENGTH-1];

always_ff @(posedge clk_i, posedge reset_i) begin
    if (reset_i) chain <= 2'b00;
    else chain <= {chain[CHAIN_LENGTH-2:0], signal_i};
end
endmodule
