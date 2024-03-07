module ss_controller(
    input logic reset_i,
    input logic clk_i,
    input logic clk_en_i,
    input logic [15:0] bin_i,
    output logic [3:0] anode_bits_o,
    output logic [6:0] cathode_bits_o
);

logic [3:0][3:0] bin;
logic [1:0] anode_index;

assign bin = bin_i;

ring_counter #(
    .NUM_BITS(4),
    .INIT_PATTERN(4'b1110)
) ring_counter_inst (
    .reset_i(reset_i),
    .clk_i(clk_i),
    .clk_en_i(clk_en_i),
    .val_o(anode_bits_o)
);

bss_decoder bss_decoder_inst (
    .bin_i(bin[anode_index]),
    .cathode_bits_o(cathode_bits_o)
);

always_comb begin
    anode_index = {anode_bits_o[1] & anode_bits_o[0], anode_bits_o[2] & anode_bits_o[0]};
end
endmodule
