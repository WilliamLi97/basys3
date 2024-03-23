`timescale 1ns/1ns

module uart_rx_tb ();

logic reset;
logic clk;
logic uart_rx;
logic data_valid;
logic [7:0] data_byte;

uart_rx uart_rx_inst (
    .reset_i(reset),
    .clk_i(clk),
    .rx_i(uart_rx),
    .valid_o(valid),
    .byte_o(data_byte)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    reset = 1;
    uart_rx = 1;
    #10;

    reset = 0;
    #104166;

    for (logic [7:0] data = 8'd0; data < 8'hf; data++) begin
        uart_rx = 0;
        #104166;

        for (int i = 0; i < 8; i++) begin
            uart_rx = data[i];
            #104166;
        end

        uart_rx = 1;
        #104166;
    end

    #500000;
    $finish();
end

initial begin
    $dumpfile(`DUMPFILE_NAME);
    $dumpvars(0, uart_rx_tb);
end
endmodule
