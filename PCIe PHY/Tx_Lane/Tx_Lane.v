module Tx_Lane
(
input rst,clk,clk1,is_kcode,is_TS_OS,
input [7:0] data_in,
input scram_en,encode_en,enable,
output out
);
wire [7:0] data_out_scrambler;
wire [9:0] data_out_encoder;
wire RD_next;
scrambler u1(rst,clk,is_kcode,is_TS_OS,scram_en,data_in,data_out_scrambler);
encode_8_to_10 u2(data_out_scrambler,rst,clk,is_kcode,encode_en,RD_next,data_out_encoder, RD_next);
serialiser u3(data_out_encoder,clk1,rst,enable,out);



endmodule
