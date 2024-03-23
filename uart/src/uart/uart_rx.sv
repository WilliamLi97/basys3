module uart_rx #(
    // 10416 tested working (9600 baud)
    parameter CLK_DIV_FACTOR = 10416    // ceil(clock frequency / target baud rate)
) (
    input logic reset_i,
    input logic clk_i,
    input logic rx_i,
    output logic valid_o,
    output logic [7:0] byte_o
);

localparam COUNTER_MIDPOINT = CLK_DIV_FACTOR / 2;

typedef enum logic [1:0] {
    STATE_IDLE = 2'b00,
    STATE_START = 2'b01,
    STATE_DATA = 2'b10,
    STATE_STOP = 2'b11
} state_e;

logic [1:0] current_state;

logic [$clog2(CLK_DIV_FACTOR)-1:0] counter;
logic [3:0] data_counter; // one extra bit to check for underflow

always_ff @(posedge clk_i, posedge reset_i) begin
    if (reset_i) valid_o <= 1'b0;
    else begin
        case (current_state)
            STATE_IDLE: valid_o <= 1'b0;
            STATE_START: valid_o <= 1'b0;
            STATE_DATA: valid_o <= data_counter[3] ? 1'b1 : 1'b0;
            STATE_STOP: valid_o <= 1'b0;
            default: valid_o <= 1'b0;
        endcase
    end
end

always_ff @(posedge clk_i, posedge reset_i) begin
    if (reset_i) byte_o <= 8'h00;
    else begin
        case (current_state)
            STATE_IDLE: byte_o <= byte_o;
            STATE_START: byte_o <= byte_o;
            STATE_DATA: if (counter == COUNTER_MIDPOINT) byte_o <= {rx_i, byte_o[7:1]};
            STATE_STOP: byte_o <= byte_o;
            default: byte_o <= 8'h00;
        endcase
    end
end

always_ff @(posedge clk_i, posedge reset_i) begin
    if (reset_i) current_state <= STATE_IDLE;
    else begin
        case (current_state)
            STATE_IDLE: current_state <= rx_i ? STATE_IDLE : STATE_START;
            STATE_START: current_state <= counter ? STATE_START : STATE_DATA;
            STATE_DATA: current_state <= data_counter[3] ? STATE_STOP : STATE_DATA;
            STATE_STOP: current_state <= counter ? STATE_STOP : STATE_IDLE;
            default: current_state <= STATE_IDLE;
        endcase
    end
end

always_ff @(posedge clk_i, posedge reset_i) begin
    if (reset_i) data_counter <= 4'b0111;
    else begin
        case (current_state)
            STATE_IDLE: data_counter <= 4'b0111;
            STATE_START: data_counter <= 4'b0111;
            STATE_DATA: data_counter <= counter ? data_counter : data_counter - 1;
            STATE_STOP: data_counter <= 4'b0111;
            default: data_counter <= 4'b0111;
        endcase
    end
end

always_ff @(posedge clk_i, posedge reset_i) begin
    if (reset_i) counter <= CLK_DIV_FACTOR;
    else begin
        case (current_state)
            STATE_IDLE: counter <= rx_i ? counter - 1 : CLK_DIV_FACTOR;
            STATE_START: counter <= counter ? counter - 1: CLK_DIV_FACTOR;
            STATE_DATA: counter <= counter ? counter - 1 : CLK_DIV_FACTOR;
            STATE_STOP: counter <= counter ? counter - 1 : CLK_DIV_FACTOR;
            default: counter <= CLK_DIV_FACTOR;
        endcase
    end
end
endmodule
