/*
encoding converts 8-bit code to 10 bit code to be sent through link

since extra bits are present,encoding is such that dc element is zero
this is also thoroughly ensured using running disparity (RD)

RD tracks the overall DC component in previous code and current code and also gives diparity to next code
RD gives
 
for eg.
code is 1100000110 there are 6 zeroes and 4 1's meaning overall dc component is -2
if previous disparity is +1, it means next code will be sent disparity -1 (+1-2=-1)
similarly if code disparity is 0 and previous RD is +1, next disparity is +1 

Comma symbols are used for synchronization
Only K.28.1, K.28.5, and K.28.7 generate comma symbols, that contain a bit sequence of 00000 or 11111 in it
e.g. K28.5 is 101111100

other codes should not have these sequence in it

*/
module encode_8_to_10(
input [7:0]data_in, // consider H is MSB, A is LSB, data in order HGF EDCBA
input rst,
clk,
is_kcode, // differentiaites between k-code and d-code
encode_en, // enable encoding
RD_prev, // RD of prev set 
output [9:0]data_out, // a is LSB,will ne sent first,data in order abcdei fghj
output RD_next_out
);
parameter 
K28_0=8'h1C,K28_1=8'h3C,K28_2=8'h5C,K28_3=8'h7C,K28_4=8'h9C,
K28_5=8'hBC,K28_6=8'hDC,K28_7=8'hFC,K23_7=8'hF7,K27_7=8'hFB,K29_7=8'hFD,K30_7=8'hFE;

wire [4:0]data_in_5bit; //EDCBA
wire [2:0]data_in_3bit; //HGF
reg [5:0]data_out_6bit;//abcdei
reg [3:0]data_out_4bit;//fghj
reg [5:0]data_out_k6bit;//abcdei
reg [3:0]data_out_k4bit;//fghj
reg [9:0] data_out_reg;
reg RD_next_reg;
reg RD_next_kreg;
reg RD_6bit;
reg RD_4bit;
reg [2:0]count;
// only k-codes comma is allowed consecutive 5 1's or 0's since it is used for synchronisation
// we need to prevent this condition in d-codes

assign data_in_5bit=data_in[4:0];
assign data_in_3bit=data_in[7:5];
assign data_out=data_out_reg;
assign RD_next_out=RD_next_reg;

always @(*)
begin
	case({data_in_3bit, data_in_5bit})
		K28_0:
		begin
			if(RD_prev) {data_out_k6bit,data_out_k4bit}=10'b1100001011;
			else {data_out_k6bit,data_out_k4bit}=10'b0011110100;
		end
		K28_1:
		begin
			if(RD_prev) {data_out_k6bit,data_out_k4bit}=10'b1100000110;
			else {data_out_k6bit,data_out_k4bit}=10'b0011111001;
		end
		K28_2:
		begin
			if(RD_prev) {data_out_k6bit,data_out_k4bit}=10'b1100001010;
			else {data_out_k6bit,data_out_k4bit}=10'b0011110101;
		end
		K28_3:
		begin
			if(RD_prev) {data_out_k6bit,data_out_k4bit}=10'b1100001100;
			else {data_out_k6bit,data_out_k4bit}=10'b0011110011;
		end
		K28_4:
		begin
			if(RD_prev) {data_out_k6bit,data_out_k4bit}=10'b1100001101;
			else {data_out_k6bit,data_out_k4bit}=10'b0011110010	;
		end
		K28_5:
		begin
			if(RD_prev) {data_out_k6bit,data_out_k4bit}=10'b1100000101;
			else {data_out_k6bit,data_out_k4bit}=10'b0011111010;
		end
		K28_6:
		begin
			if(RD_prev) {data_out_k6bit,data_out_k4bit}=10'b1100001001;
			else {data_out_k6bit,data_out_k4bit}=10'b0011110110;
		end
		K28_7:
		begin
			if(RD_prev) {data_out_k6bit,data_out_k4bit}=10'b1100000111;
			else {data_out_k6bit,data_out_k4bit}=10'b0011111000;
		end
		K23_7:
		begin
			if(RD_prev) {data_out_k6bit,data_out_k4bit}=10'b0001010111;
			else {data_out_k6bit,data_out_k4bit}=10'b1110101000;
		end
		K27_7:
		begin
			if(RD_prev) {data_out_k6bit,data_out_k4bit}=10'b0010010111;
			else {data_out_k6bit,data_out_k4bit}=10'b1101101000;
		end
		K29_7:
		begin
			if(RD_prev) {data_out_k6bit,data_out_k4bit}=10'b0100010111;
			else {data_out_k6bit,data_out_k4bit}=10'b1011101000;
		end
		K30_7:
		begin
			if(RD_prev) {data_out_k6bit,data_out_k4bit}=10'b1000010111;
			else {data_out_k6bit,data_out_k4bit}=10'b0111101000;
		end
		default:
		begin
			{data_out_k6bit,data_out_k4bit}=10'h00;
		end
	endcase
		case(data_in_5bit)
		5'd0:
		begin
			if(RD_prev) data_out_6bit=6'b011000;
			else data_out_6bit=6'b100111;
		end
		5'd1:
		begin
			if(RD_prev) data_out_6bit=6'b100010;
			else data_out_6bit=6'b011101;
		end
		5'd2:
		begin
			if(RD_prev) data_out_6bit=6'b010010;
			else data_out_6bit=6'b101101;
		end
		5'd3:
		begin
			if(RD_prev) data_out_6bit=6'b110001;
			else data_out_6bit=6'b110001;
		end
		5'd4:
		begin
			if(RD_prev) data_out_6bit=6'b001010;
			else data_out_6bit=6'b110101;
		end
		5'd5:
		begin
			if(RD_prev) data_out_6bit=6'b101001;
			else data_out_6bit=6'b101001;
		end
		5'd6:
		begin
			if(RD_prev) data_out_6bit=6'b011001;
			else data_out_6bit=6'b011001;
		end
		5'd7:
		begin
			if(RD_prev) data_out_6bit=6'b000111;
			else data_out_6bit=6'b111000;
		end
		5'd8:
		begin
			if(RD_prev) data_out_6bit=6'b000110;
			else data_out_6bit=6'b111001;
		end
		5'd9:
		begin
			if(RD_prev) data_out_6bit=6'b100101;
			else data_out_6bit=6'b100101;
		end
		5'd10:
		begin
			if(RD_prev) data_out_6bit=6'b010101;
			else data_out_6bit=6'b010101;
		end
		5'd11:
		begin
			if(RD_prev) data_out_6bit=6'b110100;
			else data_out_6bit=6'b110100;
		end
		5'd12:
		begin
			if(RD_prev) data_out_6bit=6'b001101;
			else data_out_6bit=6'b001101;
		end
		5'd13:
		begin
			if(RD_prev) data_out_6bit=6'b101100;
			else data_out_6bit=6'b101100;
		end
		5'd14:
		begin
			if(RD_prev) data_out_6bit=6'b011100;
			else data_out_6bit=6'b011100;
		end
		5'd15:
		begin
			if(RD_prev) data_out_6bit=6'b101000;
			else data_out_6bit=6'b010111;
		end
		5'd16:
		begin
			if(RD_prev) data_out_6bit=6'b100100;
			else data_out_6bit=6'b011011;
		end
		5'd17:
		begin
			if(RD_prev) data_out_6bit=6'b100011;
			else data_out_6bit=6'b100011;
		end
		5'd18:
		begin
			if(RD_prev) data_out_6bit=6'b010011;
			else data_out_6bit=6'b010011;
		end
		5'd19:
		begin
			if(RD_prev) data_out_6bit=6'b110010;
			else data_out_6bit=6'b110010;
		end
		5'd20:
		begin
			if(RD_prev) data_out_6bit=6'b001011;
			else data_out_6bit=6'b001011;
		end
		5'd21:
		begin
			if(RD_prev) data_out_6bit=6'b101010;
			else data_out_6bit=6'b101010;
		end
		5'd22:
		begin
			if(RD_prev) data_out_6bit=6'b011010;
			else data_out_6bit=6'b011010;
		end
		5'd23:
		begin
			if(RD_prev) data_out_6bit=6'b000101;
			else data_out_6bit=6'b111010;
		end
		5'd24:
		begin
			if(RD_prev) data_out_6bit=6'b001100;
			else data_out_6bit=6'b110011;
		end
		5'd25:
		begin
			if(RD_prev) data_out_6bit=6'b100110;
			else data_out_6bit=6'b100110;
		end
		5'd26:
		begin
			if(RD_prev) data_out_6bit=6'b010110;
			else data_out_6bit=6'b010110;
		end
		5'd27:
		begin
			if(RD_prev) data_out_6bit=6'b001001;
			else data_out_6bit=6'b110110;
		end
		5'd28:
		begin
			if(RD_prev) data_out_6bit=6'b001110;
			else data_out_6bit=6'b001110;
		end
		5'd29:
		begin
			if(RD_prev) data_out_6bit=6'b010001;
			else data_out_6bit=6'b101110;
		end
		5'd30:
		begin
			if(RD_prev) data_out_6bit=6'b100001;
			else data_out_6bit=6'b011110;
		end
		5'd31:
		begin
			if(RD_prev) data_out_6bit=6'b010100;
			else data_out_6bit=6'b101011;
		end
		endcase
		
		case(data_in_3bit)
		3'd0:
		begin
			if(RD_prev) 
			begin
				if
				(
				data_in_5bit==5'd3||data_in_5bit==5'd5||data_in_5bit==5'd6||data_in_5bit==5'd7||
				data_in_5bit==5'd9||data_in_5bit==5'd10||data_in_5bit==5'd11||data_in_5bit==5'd12||
				data_in_5bit==5'd13||data_in_5bit==5'd14||data_in_5bit==5'd17||data_in_5bit==5'd18||
				data_in_5bit==5'd19||data_in_5bit==5'd20||data_in_5bit==5'd21||data_in_5bit==5'd22||
				data_in_5bit==5'd25||data_in_5bit==5'd26||data_in_5bit==5'd28
				)
					data_out_4bit=4'b0100;
				else
					data_out_4bit=4'b1011;
			end
			else 
			begin
				if
				(
				data_in_5bit==5'd3||data_in_5bit==5'd5||data_in_5bit==5'd6||data_in_5bit==5'd7||
				data_in_5bit==5'd9||data_in_5bit==5'd10||data_in_5bit==5'd11||data_in_5bit==5'd12||
				data_in_5bit==5'd13||data_in_5bit==5'd14||data_in_5bit==5'd17||data_in_5bit==5'd18||
				data_in_5bit==5'd19||data_in_5bit==5'd20||data_in_5bit==5'd21||data_in_5bit==5'd22||
				data_in_5bit==5'd25||data_in_5bit==5'd26||data_in_5bit==5'd28
				)
					data_out_4bit=4'b1011;
				else
					data_out_4bit=4'b0100;
			end
		end
		3'd1:
		begin
			data_out_4bit=4'b1001;
		end
		3'd2:
		begin
			data_out_4bit=4'b0101;
		end
		3'd3:
		begin
			if(RD_prev) 
			begin
				if
				(
				data_in_5bit==5'd3||data_in_5bit==5'd5||data_in_5bit==5'd6||data_in_5bit==5'd7||
				data_in_5bit==5'd9||data_in_5bit==5'd10||data_in_5bit==5'd11||data_in_5bit==5'd12||
				data_in_5bit==5'd13||data_in_5bit==5'd14||data_in_5bit==5'd17||data_in_5bit==5'd18||
				data_in_5bit==5'd19||data_in_5bit==5'd20||data_in_5bit==5'd21||data_in_5bit==5'd22||
				data_in_5bit==5'd25||data_in_5bit==5'd26||data_in_5bit==5'd28
				)
					data_out_4bit=4'b0011;
				else
					data_out_4bit=4'b1100;
			end
			else 
			begin
				if
				(
				data_in_5bit==5'd3||data_in_5bit==5'd5||data_in_5bit==5'd6||data_in_5bit==5'd7||
				data_in_5bit==5'd9||data_in_5bit==5'd10||data_in_5bit==5'd11||data_in_5bit==5'd12||
				data_in_5bit==5'd13||data_in_5bit==5'd14||data_in_5bit==5'd17||data_in_5bit==5'd18||
				data_in_5bit==5'd19||data_in_5bit==5'd20||data_in_5bit==5'd21||data_in_5bit==5'd22||
				data_in_5bit==5'd25||data_in_5bit==5'd26||data_in_5bit==5'd28
				)
					data_out_4bit=4'b1100;
				else
					data_out_4bit=4'b0011;
			end
		end
		3'd4:
		begin
			if(RD_prev) 
			begin
				if
				(
				data_in_5bit==5'd3||data_in_5bit==5'd5||data_in_5bit==5'd6||data_in_5bit==5'd7||
				data_in_5bit==5'd9||data_in_5bit==5'd10||data_in_5bit==5'd11||data_in_5bit==5'd12||
				data_in_5bit==5'd13||data_in_5bit==5'd14||data_in_5bit==5'd17||data_in_5bit==5'd18||
				data_in_5bit==5'd19||data_in_5bit==5'd20||data_in_5bit==5'd21||data_in_5bit==5'd22||
				data_in_5bit==5'd25||data_in_5bit==5'd26||data_in_5bit==5'd28
				)
					data_out_4bit=4'b0010;
				else
					data_out_4bit=4'b1101;
			end
			else 
			begin
				if
				(
				data_in_5bit==5'd3||data_in_5bit==5'd5||data_in_5bit==5'd6||data_in_5bit==5'd7||
				data_in_5bit==5'd9||data_in_5bit==5'd10||data_in_5bit==5'd11||data_in_5bit==5'd12||
				data_in_5bit==5'd13||data_in_5bit==5'd14||data_in_5bit==5'd17||data_in_5bit==5'd18||
				data_in_5bit==5'd19||data_in_5bit==5'd20||data_in_5bit==5'd21||data_in_5bit==5'd22||
				data_in_5bit==5'd25||data_in_5bit==5'd26||data_in_5bit==5'd28
				)
					data_out_4bit=4'b1101;
				else
					data_out_4bit=4'b0010;
			end
		end
		3'd5:
		begin
			data_out_4bit=4'b1010;
		end
		3'd6:
		begin
			data_out_4bit=4'b0110;
		end
		3'd7: 
		begin
			if(RD_prev) 
			begin
				if
				(
				data_in_5bit==5'd3||data_in_5bit==5'd5||data_in_5bit==5'd6||data_in_5bit==5'd7||
				data_in_5bit==5'd9||data_in_5bit==5'd10||data_in_5bit==5'd11||data_in_5bit==5'd12||
				data_in_5bit==5'd13||data_in_5bit==5'd14||data_in_5bit==5'd17||data_in_5bit==5'd18||
				data_in_5bit==5'd19||data_in_5bit==5'd20||data_in_5bit==5'd21||data_in_5bit==5'd22||
				data_in_5bit==5'd25||data_in_5bit==5'd26||data_in_5bit==5'd28
				)
					data_out_4bit=4'b0001;
				else
					data_out_4bit=4'b1110;
			end
			else 
			begin
				if
				(
				data_in_5bit==5'd3||data_in_5bit==5'd5||data_in_5bit==5'd6||data_in_5bit==5'd7||
				data_in_5bit==5'd9||data_in_5bit==5'd10||data_in_5bit==5'd11||data_in_5bit==5'd12||
				data_in_5bit==5'd13||data_in_5bit==5'd14||data_in_5bit==5'd17||data_in_5bit==5'd18||
				data_in_5bit==5'd19||data_in_5bit==5'd20||data_in_5bit==5'd21||data_in_5bit==5'd22||
				data_in_5bit==5'd25||data_in_5bit==5'd26||data_in_5bit==5'd28
				)
					data_out_4bit=4'b1110;
				else
					data_out_4bit=4'b0001;
			end
		end
		endcase
end

always @(posedge clk or negedge rst)
begin
	if(!rst)
	begin
		data_out_reg<=10'h00;
		RD_next_reg<=1'h0;
		count<=3'h0;
	end
	else
	begin
		if(encode_en)
		begin
			if(is_kcode)
			begin
			count=3'h0;
			data_out_reg<={data_out_k6bit,data_out_k4bit};
			if(data_out_k4bit[0]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_out_k4bit[1]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_out_k4bit[2]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_out_k4bit[3]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_out_k6bit[0]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_out_k6bit[1]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_out_k6bit[2]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_out_k6bit[3]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_out_k6bit[4]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_out_k6bit[5]==1'b1)
				count=count+1'b1;
			else
				count=count;
				
			if(count==3'd5)
				RD_next_reg<=RD_prev;
			else
				RD_next_reg<=~RD_prev;
			end
			else
			begin
			count=3'h0;
			data_out_reg<={data_out_6bit,data_out_4bit};
			if(data_out_4bit[0]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_out_4bit[1]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_out_4bit[2]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_out_4bit[3]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_out_6bit[0]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_out_6bit[1]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_out_6bit[2]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_out_6bit[3]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_out_6bit[4]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_out_6bit[5]==1'b1)
				count=count+1'b1;
			else
				count=count;
				
			if(count==3'd5)
				RD_next_reg=RD_prev;
			else
				RD_next_reg=~RD_prev;
			end
		end
		else
		begin
			data_out_reg<=data_out_reg;
			count<=count;
			RD_next_reg<=RD_next_reg;
		end
	end
end

endmodule