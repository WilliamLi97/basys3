module uart_rx (
    input logic reset_i,
    input logic clk_i,
    input logic rx_i,
    output logic valid_o,
    output logic [7:0] byte_o
);

typedef enum logic [1:0] {
    STATE_IDLE = 2'b00,
    STATE_START = 2'b01,
    STATE_DATA = 2'b10
} state_e;

logic [1:0] current_state;
logic [13:0] counter;

logic rx_falling;
logic [2:0] data_counter;
logic data_counter_underflow;

fall_detector rx_fall_detector_inst (
    .reset_i(reset_i),
    .clk_i(clk_i),
    .signal_i(rx_i),
    .falling_o(rx_falling)
);

rise_detector fall_detector_inst (
    .reset_i(reset_i),
    .clk_i(clk_i),
    .signal_i(data_counter[2]),
    .falling_o(data_counter_underflow)
);

always_comb begin
    valid_o = current_state == STATE_DATA && data_counter_underflow ? 1'b1 : 1'b0;
end

always_ff @(posedge clk_i, posedge reset_i) begin
    if (reset_i) byte_o <= 8'd0;
    else begin
        case (current_state)
            STATE_IDLE: byte_o <= byte_o;
            STATE_START: byte_o <= byte_o;
            STATE_DATA: if (counter == 14'd5208) for (int i = 0; i < 8; i++) byte_o[i] <= i == 7 ? rx_i : byte_o[i+1];
            default: byte_o <= 8'd0;
        endcase
    end
end

always_ff @(posedge clk_i, posedge reset_i) begin
    if (reset_i) data_counter <= 3'd7;
    else begin
        case (current_state)
            STATE_IDLE: data_counter <= 3'd7;
            STATE_START: data_counter <= 3'd7;
            STATE_DATA: if (counter == 14'd5208) data_counter <= data_counter - 1;
            default: data_counter <= 3'd7;
        endcase
    end
end

always_ff @(posedge clk_i, posedge reset_i) begin
    if (reset_i) counter <= 14'd10416;
    else begin
        case (current_state)
            STATE_IDLE: counter <= rx_falling ? counter - 1 : 14'd10416;
            STATE_START: counter <= counter ? counter - 1 : 14'd10416;
            STATE_DATA: counter <= counter ? counter - 1 : 14'd10416;
            default: counter <= 14'd10416;
        endcase
    end
end

always_ff @(posedge clk_i, posedge reset_i) begin
    if (reset_i) current_state <= STATE_IDLE;
    else begin
        case (current_state)
            STATE_IDLE: current_state <= rx_falling ? STATE_START : STATE_IDLE;
            STATE_START: current_state <= counter ? STATE_START : STATE_DATA;
            STATE_DATA: current_state <= data_counter_underflow ? STATE_IDLE: STATE_DATA;
            default: current_state <= STATE_IDLE;
        endcase
    end
end
endmodule
