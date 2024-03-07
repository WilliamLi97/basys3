module ss_top_tb ();

logic reset_sw;
logic clk;
logic btn;
logic anode_bits;
logic ss_bits;

ss_top_tb ss_top_inst (
    .sw(reset_sw),
    .clk(clk),
    .btnC(btn),
    .an(anode_bits),
    .seg(ss_bits)
);



endmodule
