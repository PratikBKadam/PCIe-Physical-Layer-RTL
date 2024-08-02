module Rx_Lane(
input clk,clk_serial,rst,enable,decoder_en,descram_en,data_in,
input data_in_TS_OS,
output error,
output [7:0]data_out,
output is_kcode
);
wire RD_prev;
wire [9:0]data_out_deserialiser;
wire [7:0]data_out_decoder;

deserialiser u1(data_in,clk_serial,rst,enable,data_out_deserialiser);
decode_10_to_8 u2(data_out_deserialiser,rst,clk,decoder_en,RD_prev,is_kcode,data_out_decoder,RD_prev,error);
descrambler u3(rst,clk,is_kcode,data_in_TS_OS,descram_en,data_out_decoder,data_out);
endmodule
