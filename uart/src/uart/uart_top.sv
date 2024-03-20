module uart_top (
    input logic reset,
    input logic clk,
    input logic rx,
    output logic tx
);

logic rx_valid;
logic rx_data;

uart_rx uart_rx_inst (
    .reset_i(reset),
    .clk_i(clk),
    .rx_i(rx),
    .valid_o(rx_valid),
    .byte_o(rx_data)
);
endmodule
