`timescale 1ns/1ns

module uart_tx_tb();

logic reset;
logic clk;
logic w_en;
logic [7:0] data;

logic tx;
logic tx_busy;

uart_tx uart_tx_inst (
    .reset_i(reset),
    .clk_i(clk),
    .write_en_i(w_en),
    .byte_i(data),
    .busy_o(tx_busy),
    .tx_o(tx)
);

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

initial begin
    reset = 1'b1;
    w_en = 1'b0;
    data = 8'd0;
    #10;

    reset = 1'b0;
    #10;

    w_en = 1;
    data = 8'd7;
    #10;

    w_en = 0;
    while (tx_busy) #10;

    w_en = 1;
    data = 8'b10011001;
    #10;

    w_en = 0;
    while (tx_busy) #10;

    w_en = 1;
    data = 8'b01101001;
    #10;

    w_en = 0;
    data = 8'd0;
    while (tx_busy) #10;

    #500000;
    $finish();
end

initial begin
    $dumpfile(`DUMPFILE_NAME);
    $dumpvars(0, uart_tx_tb);
end
endmodule
