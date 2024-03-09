`timescale 1ns / 1ns

module ss_controller_tb ();

logic reset;
logic clk;
logic [3:0][3:0] bin;
logic [3:0] anode_bits;
logic [6:0] cathode_bits;

logic [1:0] anode_index;
logic [3:0] cathode_hex;

ss_controller ss_controller_inst (
    .reset_i(reset),
    .clk_i(clk),
    .clk_en_i(1'b1),
    .bin_i(bin),
    .anode_bits_o(anode_bits),
    .cathode_bits_o(cathode_bits)
);

always_comb begin
    case (anode_bits)
        4'b1110: anode_index = 2'd0;
        4'b1101: anode_index = 2'd1;
        4'b1011: anode_index = 2'd2;
        4'b0111: anode_index = 2'd3;
        default: anode_index = 2'd0;
    endcase
end

always_comb begin
    case (cathode_bits)
        7'b1000000: cathode_hex = 4'h0;
        7'b1111001: cathode_hex = 4'h1;
        7'b0100100: cathode_hex = 4'h2;
        7'b0110000: cathode_hex = 4'h3;
        7'b0011001: cathode_hex = 4'h4;
        7'b0010010: cathode_hex = 4'h5;
        7'b0000010: cathode_hex = 4'h6;
        7'b1111000: cathode_hex = 4'h7;
        7'b0000000: cathode_hex = 4'h8;
        7'b0010000: cathode_hex = 4'h9;
        7'b0001000: cathode_hex = 4'ha;
        7'b0000011: cathode_hex = 4'hb;
        7'b1000110: cathode_hex = 4'hc;
        7'b0100001: cathode_hex = 4'hd;
        7'b0000110: cathode_hex = 4'he;
        7'b0001110: cathode_hex = 4'hf;
        default: cathode_hex = 4'h0;
    endcase
end

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    reset = 1;
    bin = 16'h0000;
    #10;

    reset = 0;
    for (int i = 0; i <= 16'hffff; i++) begin
        bin = i;
        #10;
    end

    #100;
    $finish();
end

always_ff @(posedge clk) begin
    if (bin[anode_index] != cathode_hex) $display("%d error: expected bin[%d] = %x but got %x", $time, anode_index, bin[anode_index], cathode_hex);
end

initial begin
    $dumpfile(`DUMPFILE_NAME);
    $dumpvars(0, ss_controller_tb);
end
endmodule
