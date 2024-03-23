module uart_top (
    input logic reset,
    input logic clk,
    input logic RsRx,
    output logic RsTx,
    output logic [7:0] led
);

logic rx_sync;

logic rx_valid;
logic [7:0] rx_data;

logic write_en;
logic [7:0] tx_data;
logic tx_busy;

synchronizer rx_synchronizer_inst (
    .reset_i(reset),
    .clk_i(clk),
    .signal_i(RsRx),
    .signal_o(rx_sync)
);

// target 4 Mbaud
uart_rx #(
    .CLK_DIV_FACTOR(25)
) uart_rx_inst (
    .reset_i(reset),
    .clk_i(clk),
    .rx_i(rx_sync),
    .valid_o(rx_valid),
    .byte_o(rx_data)
);

// target 4 Mbaud
uart_tx #(
    .CLK_DIV_FACTOR(25)
) uart_tx_inst (
    .reset_i(reset),
    .clk_i(clk),
    .write_en_i(write_en),
    .byte_i(tx_data),
    .busy_o(tx_busy),
    .tx_o(RsTx)
);

always_ff @(posedge clk, posedge reset) begin
    if (reset) led <= 8'hff;
    else if (rx_valid) led <= rx_data;
end

always_ff @(posedge clk, posedge reset) begin
    if (reset) tx_data <= 8'h00;
    else if (rx_valid) tx_data <= rx_data;
end

always_ff @(posedge clk, posedge reset) begin
    if (reset) write_en <= 1'b0;
    else write_en <= tx_busy ? 1'b0 : rx_valid;
end
endmodule
