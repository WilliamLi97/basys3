module bss_decoder (
    input logic [3:0] bin_i,
    output logic [6:0] cathode_bits_o
);

typedef enum logic [6:0] {
    CATHODE_BITS_0 = 7'b1000000,
    CATHODE_BITS_1 = 7'b1111001,
    CATHODE_BITS_2 = 7'b0100100,
    CATHODE_BITS_3 = 7'b0110000,
    CATHODE_BITS_4 = 7'b0011001,
    CATHODE_BITS_5 = 7'b0010010,
    CATHODE_BITS_6 = 7'b0000010,
    CATHODE_BITS_7 = 7'b1111000,
    CATHODE_BITS_8 = 7'b0000000,
    CATHODE_BITS_9 = 7'b0010000,
    CATHODE_BITS_A = 7'b0001000,
    CATHODE_BITS_B = 7'b0000011,
    CATHODE_BITS_C = 7'b1000110,
    CATHODE_BITS_D = 7'b0100001,
    CATHODE_BITS_E = 7'b0000110,
    CATHODE_BITS_F = 7'b0001110
} cathode_bits_e;

always_comb begin
    case (bin_i)
        4'h0: cathode_bits_o = CATHODE_BITS_0;
        4'h1: cathode_bits_o = CATHODE_BITS_1;
        4'h2: cathode_bits_o = CATHODE_BITS_2;
        4'h3: cathode_bits_o = CATHODE_BITS_3;
        4'h4: cathode_bits_o = CATHODE_BITS_4;
        4'h5: cathode_bits_o = CATHODE_BITS_5;
        4'h6: cathode_bits_o = CATHODE_BITS_6;
        4'h7: cathode_bits_o = CATHODE_BITS_7;
        4'h8: cathode_bits_o = CATHODE_BITS_8;
        4'h9: cathode_bits_o = CATHODE_BITS_9;
        4'ha: cathode_bits_o = CATHODE_BITS_A;
        4'hb: cathode_bits_o = CATHODE_BITS_B;
        4'hc: cathode_bits_o = CATHODE_BITS_C;
        4'hd: cathode_bits_o = CATHODE_BITS_D;
        4'he: cathode_bits_o = CATHODE_BITS_E;
        default: cathode_bits_o = CATHODE_BITS_F;
    endcase
end
endmodule
