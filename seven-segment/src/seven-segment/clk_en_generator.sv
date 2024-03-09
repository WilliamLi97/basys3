module clk_en_generator #(
    parameter COUNTER_BITS_NUM = 17
) (
    input logic reset_i,
    input logic clk_i,
    output logic clk_en_o
);

logic [COUNTER_BITS_NUM-1:0] counter;

edge_detector edge_detector_inst (
    .reset_i(reset_i),
    .clk_i(clk_i),
    .signal_i(counter[COUNTER_BITS_NUM-1]),
    .signal_o(clk_en_o)
);

always @(posedge clk_i, posedge reset_i) begin
    if (reset_i) counter <= '0;
    else counter <= counter + 1;
end
endmodule
