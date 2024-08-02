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
module decode_10_to_8(
input [9:0]data_in, // consider H is MSB, A is LSB, data in order HGF EDCBA
input rst,
clk,
encode_en,
RD_prev, // enable encoding
output is_kcode, 
output [7:0]data_out, // a is LSB,will ne sent first,data in order abcdei fghj
output RD_next_out,
output error
);
parameter 
K28_0=8'h1C,K28_1=8'h3C,K28_2=8'h5C,K28_3=8'h7C,K28_4=8'h9C,
K28_5=8'hBC,K28_6=8'hDC,K28_7=8'hFC,K23_7=8'hF7,K27_7=8'hFB,K29_7=8'hFD,K30_7=8'hFE;

wire[5:0]data_in_6bit;
wire[3:0]data_in_4bit;
reg [4:0]data_out_5bit;//abcdei
reg [2:0]data_out_3bit;//fghj
reg [7:0]data_out_kcode;
reg [7:0] data_out_reg;
reg [2:0]count;
reg RD_next; // RD of prev set
reg k_code;
reg err;
// only k-codes comma is allowed consecutive 5 1's or 0's since it is used for synchronisation
// we need to prevent this condition in d-codes
assign data_in_6bit=data_in[9:4];
assign data_in_4bit=data_in[3:0];
assign data_out=data_out_reg;
assign RD_next_out=RD_next;
assign is_kcode=k_code;
assign error=err;

always @(*)
begin
		case(data_in)
		10'b0011110100: 
		begin
			data_out_kcode=K28_0;
			err=1'b0;
		end
		10'b1100001011: 
		begin
			data_out_kcode=K28_0;
			err=1'b0;
		end
		10'b0011111001: 
		begin
			data_out_kcode=K28_1;
			err=1'b0;
		end
		10'b1100000110: 
		begin
			data_out_kcode=K28_1;
			err=1'b0;
		end
		10'b0011110101: 
		begin
			data_out_kcode=K28_2;
			err=1'b0;
		end
		10'b1100001010: 
		begin
			data_out_kcode=K28_2;
			err=1'b0;
		end
		10'b0011110011: 
		begin
			data_out_kcode=K28_3;
			err=1'b0;
		end
		10'b1100001100: 
		begin
			data_out_kcode=K28_3;
			err=1'b0;
		end
		10'b0011110010: 
		begin
			data_out_kcode=K28_4;
			err=1'b0;
		end
		10'b1100001101: 
		begin
			data_out_kcode=K28_4;
			err=1'b0;
		end
		10'b0011111010: 
		begin
			data_out_kcode=K28_5;
			err=1'b0;
		end
		10'b1100000101: 
		begin
			data_out_kcode=K28_5;
			err=1'b0;
		end
		10'b0011110110: 
		begin
			data_out_kcode=K28_6;
			err=1'b0;
		end
		10'b1100001001: 
		begin
			data_out_kcode=K28_6;
			err=1'b0;
		end
		10'b0011111000: 
		begin
			data_out_kcode=K28_7;
			err=1'b0;
		end
		10'b1100000111: 
		begin
			data_out_kcode=K28_7;
			err=1'b0;
		end
		10'b1110101000: 
		begin
			data_out_kcode=K23_7;
			err=1'b0;
		end
		10'b0001010111: 
		begin
			data_out_kcode=K23_7;
			err=1'b0;
		end
		10'b1101101000: 
		begin
			data_out_kcode=K27_7;
			err=1'b0;
		end
		10'b0010010111: 
		begin
			data_out_kcode=K27_7;
			err=1'b0;
		end
		10'b1011101000: 
		begin
			data_out_kcode=K29_7;
			err=1'b0;
		end
		10'b0100010111: 
		begin
			data_out_kcode=K29_7;
			err=1'b0;
		end
		10'b0111101000: 
		begin
			data_out_kcode=K30_7;
			err=1'b0;
		end
		10'b1000010111: 
		begin
			data_out_kcode=K30_7;
			err=1'b0;
		end
		default:
		begin
			data_out_kcode=8'h00;
			err=1'b1;
		end
		endcase
	case(data_in_6bit)
		6'b100111:  
		begin
			data_out_5bit=5'b00000;
			err=1'b0; 
		end
		6'b011000:  
		begin
			data_out_5bit=5'b00000;
			err=1'b0;
		end
		6'b011101:  
		begin
			data_out_5bit=5'b00001;
			err=1'b0;
		end
		6'b100010:  
		begin
			data_out_5bit=5'b00001;
			err=1'b0;
		end
		6'b101101:  
		begin
			data_out_5bit=5'b00010;
			err=1'b0;
		end
		6'b010010:  
		begin
			data_out_5bit=5'b00010;
			err=1'b0;
		end
		6'b110001:  
		begin
			data_out_5bit=5'b00011;
			err=1'b0;
		end
		6'b110101:  
		begin
			data_out_5bit=5'b00100;
			err=1'b0;
		end
		6'b001010:  
		begin
			data_out_5bit=5'b00100;
			err=1'b0;
		end
		6'b101001:  
		begin
			data_out_5bit=5'b00101;
			err=1'b0;
		end
		6'b011001:  
		begin
			data_out_5bit=5'b00110;
			err=1'b0;
		end
		6'b111000:  
		begin
			data_out_5bit=5'b00111;
			err=1'b0;
		end
		6'b000111:  
		begin
			data_out_5bit=5'b00111;
			err=1'b0;
		end
		6'b111001:  
		begin
			data_out_5bit=5'b01000;
			err=1'b0;
		end
		6'b000110:  
		begin
			data_out_5bit=5'b01000;
			err=1'b0;
		end
		6'b100101:  
		begin
			data_out_5bit=5'b01001;
			err=1'b0;
		end
		6'b010101:  
		begin
			data_out_5bit=5'b01010;
			err=1'b0;
		end
		6'b110100:  
		begin
			data_out_5bit=5'b01011;
			err=1'b0;
		end
		6'b001101:  
		begin
			data_out_5bit=5'b01100;
			err=1'b0;
		end
		6'b101100:  
		begin
			data_out_5bit=5'b01101;
			err=1'b0;
		end
		6'b011100:  
		begin
			data_out_5bit=5'b01110;
			err=1'b0;
		end
		6'b010111:  
		begin
			data_out_5bit=5'b01111;
			err=1'b0;
		end
		6'b101000:  
		begin
			data_out_5bit=5'b01111;
			err=1'b0;
		end
		6'b011011:  
		begin
			data_out_5bit=5'b10000;
			err=1'b0;
		end
		6'b100100:  
		begin
			data_out_5bit=5'b10000;
			err=1'b0;
		end
		6'b100011:  
		begin
			data_out_5bit=5'b10001;
			err=1'b0;
		end
		6'b010011:  
		begin
			data_out_5bit=5'b10010;
			err=1'b0;
		end
		6'b110010:  
		begin
			data_out_5bit=5'b10011;
			err=1'b0;
		end
		6'b001011:  
		begin
			data_out_5bit=5'b10100;
			err=1'b0;
		end
		6'b101010:  
		begin
			data_out_5bit=5'b10101;
			err=1'b0;
		end
		6'b011010:  
		begin
			data_out_5bit=5'b10110;
			err=1'b0;
		end
		6'b111010:  
		begin
			data_out_5bit=5'b10111;
			err=1'b0;
		end
		6'b000101:  
		begin
			data_out_5bit=5'b10111;
			err=1'b0;
		end
		6'b110011:  
		begin
			data_out_5bit=5'b11000;
			err=1'b0;
		end
		6'b001100:  
		begin
			data_out_5bit=5'b11000;
			err=1'b0;
		end
		6'b100110:  
		begin
			data_out_5bit=5'b11001;
			err=1'b0;
		end
		6'b010110:  
		begin
			data_out_5bit=5'b11010;
			err=1'b0;
		end
		6'b110110:  
		begin
			data_out_5bit=5'b11011;
			err=1'b0;
		end
		6'b001001:  
		begin
			data_out_5bit=5'b11011;
			err=1'b0;
		end
		6'b001110:  
		begin
			data_out_5bit=5'b11100;
			err=1'b0;
		end
		6'b101110:  
		begin
			data_out_5bit=5'b11101;
			err=1'b0;
		end
		6'b010001:  
		begin
			data_out_5bit=5'b11101;
			err=1'b0;
		end
		6'b011110:  
		begin
			data_out_5bit=5'b11110;
			err=1'b0;
		end
		6'b100001:  
		begin
			data_out_5bit=5'b11110;
			err=1'b0;
		end
		6'b101011:  
		begin
			data_out_5bit=5'b11111;
			err=1'b0;
		end
		6'b010100:  
		begin
			data_out_5bit=5'b11111;
			err=1'b0;
		end
		6'b001111:  
		begin
			data_out_5bit=5'b11100;
			err=1'b0;
		end
		6'b110000:  
		begin
			data_out_5bit=5'b11100;
			err=1'b0;
		end
		default:    
		begin
			data_out_5bit=5'b00000;
			err=1'b1;
      end
		endcase
		
		case(data_in_4bit)
		4'b1011:    
		begin
			data_out_3bit=3'b000;
			err=1'b0;
		end
		4'b0100:    
		begin
			data_out_3bit=3'b000;
			err=1'b0;
		end
		4'b1001:    
		begin
			data_out_3bit=3'b001;
			err=1'b0;
		end
		4'b0101:    
		begin
			data_out_3bit=3'b010;
			err=1'b0;
		end          
		4'b1100:    
		begin
			data_out_3bit=3'b011;
			err=1'b0;
		end
		4'b0011:    
		begin
			data_out_3bit=3'b011;
			err=1'b0;
	   end
		4'b1101:    
		begin
			data_out_3bit=3'b100;
			err=1'b0;
	   end
		4'b0010:    
		begin
			data_out_3bit=3'b100;
			err=1'b0;
		end
		4'b1010:    
		begin
			data_out_3bit=3'b101;
			err=1'b0;
		end
		4'b0110:    
		begin
			data_out_3bit=3'b110;
			err=1'b0;
		end
		4'b1110:    
		begin
			data_out_3bit=3'b111;
			err=1'b0;
		end
		4'b0001:    
		begin
			data_out_3bit=3'b111;
			err=1'b0;				  
		end
		default:    
		begin
			data_out_3bit=3'h0;
			err=1'b1;
		end
	endcase
end

always @(posedge clk or negedge rst)
begin
	if(!rst)
	begin
		data_out_reg<=8'h00;
		count<=3'h0;
		RD_next<=1'b0;
		k_code<=1'b0;
	end
	else
	begin
		if(encode_en)
		begin
		if((data_in == 10'b0011110100) | (
			data_in == 10'b1100001011) | (
			data_in == 10'b0011111001) | (
			data_in == 10'b1100000110) | (
			data_in == 10'b0011110101) | (
			data_in == 10'b1100001010) | (
			data_in == 10'b0011110011) | (
			data_in == 10'b1100001100) | (
			data_in == 10'b0011110010) | (
			data_in == 10'b1100001101) | (
			data_in == 10'b0011111010) | (
			data_in == 10'b1100000101) | (
			data_in == 10'b0011110110) | (
			data_in == 10'b1100001001) | (
			data_in == 10'b0011111000) | (
			data_in == 10'b1100000111) | (
			data_in == 10'b1110101000) | (
			data_in == 10'b0001010111) | (
			data_in == 10'b1101101000) | (
			data_in == 10'b0010010111) | (
			data_in == 10'b1011101000) | (
			data_in == 10'b0100010111) | (
			data_in == 10'b0111101000) | (
			data_in == 10'b1000010111))
		begin
			data_out_reg=data_out_kcode;
			k_code=1'b1;
			count=3'h0;
			if(data_in[0]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_in[1]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_in[2]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_in[3]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_in[4]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_in[5]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_in[6]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_in[7]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_in[8]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_in[9]==1'b1)
				count=count+1'b1;
			else
				count=count;
				
			if(count==3'd5)
				RD_next=RD_prev;
			else
				RD_next=~RD_prev;
		end
		else
		begin
			data_out_reg={data_out_3bit,data_out_5bit};
			k_code=1'b0;
			count=3'h0;
			if(data_in[0]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_in[1]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_in[2]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_in[3]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_in[4]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_in[5]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_in[6]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_in[7]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_in[8]==1'b1)
				count=count+1'b1;
			else
				count=count;
			if(data_in[9]==1'b1)
				count=count+1'b1;
			else
				count=count;
				
			if(count==3'd5)
				RD_next=RD_prev;
			else
				RD_next=~RD_prev;
		end
		end
		else
		begin
			data_out_reg<=data_out_reg;
			count<=count;
			RD_next<=RD_next;
			k_code<=k_code;
		end
	end
end

endmodule
