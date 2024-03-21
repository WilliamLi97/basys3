module uart_tx (
    input logic reset_i,
    input logic clk_i,
    input logic write_en_i,
    input logic [7:0] byte_i,
    output logic busy_o,
    output logic tx_o
);

typedef enum logic [1:0] {
    STATE_IDLE = 2'b00,
    STATE_START = 2'b01,
    STATE_DATA = 2'b10,
    STATE_STOP = 2'b11
} state_e;

logic [1:0] current_state;
logic [9:0] data;

logic [13:0] counter;

logic [2:0] tx_counter;
logic tx_counter_underflow;

logic counter_debug;
assign counter_debug = !counter;

rise_detector tx_counter_underflow_detector_inst (
    .reset_i(reset_i),
    .clk_i(clk_i),
    .signal_i(tx_counter[2]),
    .rising_o(tx_counter_underflow)
);

assign tx_o = data[0];

always_ff @(posedge clk_i, posedge reset_i) begin
    if (reset_i) busy_o <= 1'b0;
    else begin
        case (current_state)
            STATE_IDLE: busy_o <= write_en_i ? 1'b1 : 1'b0;
            STATE_START: busy_o <= 1'b1;
            STATE_DATA: busy_o <= 1'b1;
            STATE_STOP: busy_o <= counter ? 1'b1 : 1'b0;
            default: busy_o <= 1'b0;
        endcase
    end
end

always_ff @(posedge clk_i, posedge reset_i) begin
    if (reset_i) data <= 10'd1;
    else begin
        case (current_state)
            STATE_IDLE: data <= write_en_i ? {1'b1, byte_i, data[1]} : data;
            STATE_START: data <= counter ? data : {1'b1, data[9:1]};
            STATE_DATA: data <= tx_counter_underflow ? 10'd1 : counter ? data : {1'b1, data[9:1]};
            STATE_STOP: data <= 10'd1;
            default: data <= 10'd1;
        endcase
    end
end

always_ff @(posedge clk_i, posedge reset_i) begin
    if (reset_i) tx_counter <= 3'd7;
    else begin
        case (current_state)
            STATE_IDLE: tx_counter <= 3'd7;
            STATE_START: tx_counter <= 3'd7;
            STATE_DATA: tx_counter <= counter ? tx_counter : tx_counter - 1;
            STATE_STOP: tx_counter <= 3'd7;
            default: tx_counter <= 3'd7;
        endcase
    end
end

always_ff @(posedge clk_i, posedge reset_i) begin
    if (reset_i) counter <= 14'd10415;
    else begin
        case (current_state)
            STATE_IDLE: counter <= write_en_i ? counter - 1 : 14'd10415;
            STATE_START: counter <= counter ? counter - 1 : 14'd10415;
            STATE_DATA: counter <= counter ? counter - 1 : 14'd10415;
            STATE_STOP: counter <= counter ? counter - 1 : 14'd10415;
            default: counter <= 14'd10415;
        endcase
    end
end

always_ff @(posedge clk_i, posedge reset_i) begin
    if (reset_i) current_state <= STATE_IDLE;
    else begin
        case (current_state)
            STATE_IDLE: current_state <= write_en_i ? STATE_START : STATE_IDLE;
            STATE_START: current_state <= counter ? STATE_START : STATE_DATA;
            STATE_DATA: current_state <= tx_counter_underflow ? STATE_STOP : STATE_DATA;
            STATE_STOP: current_state <= counter ? STATE_STOP : STATE_IDLE;
            default: current_state <= STATE_IDLE;
        endcase
    end
end
endmodule
