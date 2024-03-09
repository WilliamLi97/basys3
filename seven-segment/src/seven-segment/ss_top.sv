module ss_top (
    input logic sw,
    input logic clk,
    input logic btnC,
    output logic [3:0] an,
    output logic [6:0] seg
);

logic reset;
logic clk_en;
logic button;
logic button_rising;
logic [15:0] bin;

clk_en_generator #(
    .COUNTER_BITS_NUM(17)
) clk_en_generator_inst (
    .reset_i(reset),
    .clk_i(clk),
    .clk_en_o(clk_en)
);

synchronizer #(
    .CHAIN_LENGTH(2)
) sw_synchronizer_inst (
    .clk_i(clk),
    .clk_en_i(1'b1),
    .signal_i(sw),
    .signal_o(reset)
);

synchronizer #(
    .CHAIN_LENGTH(2)
) btn_synchronizer_inst (
    .clk_i(clk),
    .clk_en_i(clk_en),
    .signal_i(btnC),
    .signal_o(button)
);

edge_detector edge_detector_inst (
    .reset_i(reset),
    .clk_i(clk),
    .signal_i(button),
    .signal_o(button_rising)
);

ss_controller ss_controller_inst (
    .reset_i(reset),
    .clk_i(clk),
    .clk_en_i(clk_en),
    .bin_i(bin),
    .anode_bits_o(an),
    .cathode_bits_o(seg)
);

always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        bin <= '0;
    end else begin
        bin <= button_rising ? bin + 1 : bin;
    end
end
endmodule
