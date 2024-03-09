module edge_detector(
    input logic reset_i,
    input logic clk_i,
    input logic signal_i,
    output logic signal_o
);

logic signal_1;

always_comb begin
    signal_o = signal_i & ~signal_1;
end

always_ff @(posedge clk_i, posedge reset_i) begin
    if (reset_i) signal_1 <= '0;
    else signal_1 <= signal_i;
end
endmodule
