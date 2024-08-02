module frame_generator(
input clk,rst,
input [63:0] data_in_LTSSM,
input TLP_sent,DLLP_sent,nullified_TLP_sent,framer_en,
input [31:0] data_in_DLL,
output reg [7:0] data_1,data_2,data_3,data_4,
output sender_error_LTSSM,sender_error_DLL);
wire buffer_en_LTSSM,buffer_en_DLL;
reg [63:0]buffer;
reg sel1,sel2,first;
reg [1:0] os_seq;
/*
data_in_LTSSM[63:24]= data (for TS1 and TS2 OS)
data_in_LTSSM[23:19] ={TS1_OS,TS2_OS,EIOS,EIEOS,FTS}
data_in_LTSSM[15:0] = number

*/
// K29_7=END, K30_7=EDB, K27_7=STP, K28_2=SDP
parameter
//  D-codes and K- codes used in ordered sets
D0_0=8'h00,D1_0=8'h01,D2_0=8'h02,D3_0=8'h03,D4_0=8'h04,D5_0=8'h05,D6_0=8'h06,D7_0=8'h07,D8_0=8'h08,D9_0=8'h09,D10_0=8'h0A,
D11_0=8'h0B,D12_0=8'h0C,D13_0=8'h0D,D14_0=8'h0E,D15_0=8'h0F,D16_0=8'h10,D17_0=8'h11,D18_0=8'h12,D19_0=8'h13,D20_0=8'h14,
D21_0=8'h15,D22_0=8'h16,D23_0=8'h17,D24_0=8'h18,D25_0=8'h19,D26_0=8'h1A,D27_0=8'h1B,D28_0=8'h1C,D29_0=8'h1D,D30_0=8'h1E,
D31_0=8'h1F,D0_1=8'h20,D1_1=8'h21,D2_1=8'h22,D3_1=8'h23,D4_1=8'h24,D5_1=8'h25,D6_1=8'h26,D7_1=8'h27,D8_1=8'h28,D9_1=8'h29,D10_1=8'h2A,
D11_1=8'h2B,D12_1=8'h2C,D13_1=8'h2D,D14_1=8'h2E,D15_1=8'h2F,D16_1=8'h30,D17_1=8'h31,D18_1=8'h32,D19_1=8'h33,D20_1=8'h34,
D21_1=8'h35,D22_1=8'h36,D23_1=8'h37,D24_1=8'h38,D25_1=8'h39,D26_1=8'h3A,D27_1=8'h3B,D28_1=8'h3C,D29_1=8'h3D,D30_1=8'h3E,
D31_1=8'h3F,D0_2=8'h40,D1_2=8'h41,D2_2=8'h42,D3_2=8'h43,D4_2=8'h44,D5_2=8'h45,D6_2=8'h46,D7_2=8'h47,D8_2=8'h48,D9_2=8'h49,D10_2=8'h4A,
D11_2=8'h4B,D12_2=8'h4C,D13_2=8'h4D,D14_2=8'h4E,D15_2=8'h4F,D16_2=8'h50,D17_2=8'h51,D18_2=8'h52,D19_2=8'h53,D20_2=8'h54,
D21_2=8'h55,D22_2=8'h56,D23_2=8'h57,D24_2=8'h58,D25_2=8'h59,D26_2=8'h5A,D27_2=8'h5B,D28_2=8'h5C,D29_2=8'h5D,D30_2=8'h5E,
D31_2=8'h5F,D0_3=8'h60,D1_3=8'h61,D2_3=8'h62,D3_3=8'h63,D4_3=8'h64,D5_3=8'h65,D6_3=8'h66,D7_3=8'h67,D8_3=8'h68,D9_3=8'h69,D10_3=8'h6A,
D11_3=8'h6B,D12_3=8'h6C,D13_3=8'h6D,D14_3=8'h6E,D15_3=8'h6F,D16_3=8'h70,D17_3=8'h71,D18_3=8'h72,D19_3=8'h73,D20_3=8'h74,
D21_3=8'h75,D22_3=8'h76,D23_3=8'h77,D24_3=8'h78,D25_3=8'h79,D26_3=8'h7A,D27_3=8'h7B,D28_3=8'h7C,D29_3=8'h7D,D30_3=8'h7E,
D31_3=8'h7F,D0_4=8'h80,D1_4=8'h81,D2_4=8'h82,D3_4=8'h83,D4_4=8'h84,D5_4=8'h85,D6_4=8'h86,D7_4=8'h87,D8_4=8'h88,D9_4=8'h89,D10_4=8'h8A,
D11_4=8'h8B,D12_4=8'h8C,D13_4=8'h8D,D14_4=8'h8E,D15_4=8'h8F,D16_4=8'h90,D17_4=8'h91,D18_4=8'h92,D19_4=8'h93,D20_4=8'h94,
D21_4=8'h95,D22_4=8'h96,D23_4=8'h97,D24_4=8'h98,D25_4=8'h99,D26_4=8'h9A,D27_4=8'h9B,D28_4=8'h9C,D29_4=8'h9D,D30_4=8'h9E,
D31_4=8'h9F,D0_5=8'hA0,D1_5=8'hA1,D2_5=8'hA2,D3_5=8'hA3,D4_5=8'hA4,D5_5=8'hA5,D6_5=8'hA6,D7_5=8'hA7,D8_5=8'hA8,D9_5=8'hA9,D10_5=8'hAA,
D11_5=8'hAB,D12_5=8'hAC,D13_5=8'hAD,D14_5=8'hAE,D15_5=8'hAF,D16_5=8'hB0,D17_5=8'hB1,D18_5=8'hB2,D19_5=8'hB3,D20_5=8'hB4,
D21_5=8'hB5,D22_5=8'hB6,D23_5=8'hB7,D24_5=8'hB8,D25_5=8'hB9,D26_5=8'hBA,D27_5=8'hBB,D28_5=8'hBC,D29_5=8'hBD,D30_5=8'hBE,
D31_5=8'hBF,D0_6=8'hC0,D1_6=8'hC1,D2_6=8'hC2,D3_6=8'hC3,D4_6=8'hC4,D5_6=8'hC5,D6_6=8'hC6,D7_6=8'hC7,D8_6=8'hC8,D9_6=8'hC9,D10_6=8'hCA,
D11_6=8'hCB,D12_6=8'hCC,D13_6=8'hCD,D14_6=8'hCE,D15_6=8'hCF,D16_6=8'hD0,D17_6=8'hD1,D18_6=8'hD2,D19_6=8'hD3,D20_6=8'hD4,
D21_6=8'hD5,D22_6=8'hD6,D23_6=8'hD7,D24_6=8'hD8,D25_6=8'hD9,D26_6=8'hDA,D27_6=8'hDB,D28_6=8'hDC,D29_6=8'hDD,D30_6=8'hDE,
D31_6=8'hDF,D0_7=8'hE0,D1_7=8'hE1,D2_7=8'hE2,D3_7=8'hE3,D4_7=8'hE4,D5_7=8'hE5,D6_7=8'hE6,D7_7=8'hE7,D8_7=8'hE8,D9_7=8'hE9,D10_7=8'hEA,
D11_7=8'hEB,D12_7=8'hEC,D13_7=8'hED,D14_7=8'hEE,D15_7=8'hEF,D16_7=8'hF0,D17_7=8'hF1,D18_7=8'hF2,D19_7=8'hF3,D20_7=8'hF4,
D21_7=8'hF5,D22_7=8'hF6,D23_7=8'hF7,D24_7=8'hF8,D25_7=8'hF9,D26_7=8'hFA,D27_7=8'hFB,D28_7=8'hFC,D29_7=8'hFD,D30_7=8'hFE,D31_7=8'hFF,
K28_0=8'h1C,K28_1=8'h3C,K28_2=8'h5C,K28_3=8'h7C,K28_4=8'h9C,K28_5=8'hBC,K28_6=8'hDC,K28_7=8'hFC,K23_7=8'hF7,K27_7=8'hFB,K29_7=8'hFD,K30_7=8'hFE; 

assign buffer_en_DLL=({TLP_sent,DLLP_sent}==2'b01||{TLP_sent,DLLP_sent}==2'b10)?1'b1:1'b0;
assign sender_error_DLL=({TLP_sent,DLLP_sent,nullified_TLP_sent}==3'b011||{TLP_sent,DLLP_sent,nullified_TLP_sent}==3'b101||
{TLP_sent,DLLP_sent,nullified_TLP_sent}==3'b110||{TLP_sent,DLLP_sent,nullified_TLP_sent}==3'b111)?1'b1:1'b0;

assign buffer_en_LTSSM=(data_in_LTSSM[23:19]==5'b00001||data_in_LTSSM[23:19]==5'b00010||
data_in_LTSSM[23:19]==5'b00100||data_in_LTSSM[23:19]==5'b01000||data_in_LTSSM[23:19]==5'b10000)?1'b1:1'b0;

assign sender_error_LTSSM=(data_in_LTSSM[23:19]==5'b00000||buffer_en_LTSSM)?1'b0:1'b1;


always @(posedge clk or negedge rst)
begin
	if(!rst)
	begin
		buffer<=64'h0;
		data_1<=8'h0;
		data_2<=8'h0;
		data_3<=8'h0;
		data_4<=8'h0;
		sel1<=1'b0;
		sel2<=1'b0;
		first<=1'b0;
		os_seq<=2'b00;
	end
	else
	begin
		if(buffer_en_DLL||framer_en)
		begin
			if(buffer_en_DLL) // store data from DLL in buffer
			begin
				if(!sel1)
				begin
					buffer[63:32]<=data_in_DLL;
					buffer[31:0]<=buffer[31:0];
					sel1<=1'b1;
				end
				else
				begin
					buffer[31:0]<=data_in_DLL;
					buffer[63:32]<=buffer[63:32];
					sel1<=1'b0;
				end
			end
			else 
			begin
				buffer<=buffer;
				sel1<=1'b0;
			end	
			
			if(framer_en)
			begin
				if(buffer_en_DLL)
				begin
					if(!first) // for first symbol add STP or SDP
					begin
						if(DLLP_sent)
						begin
							{data_1,data_2,data_3,data_4}<={K28_2,buffer[63:40]};
							sel2<=1'b0;
							first<=1'b1;
						end
						else
						begin
							{data_1,data_2,data_3,data_4}<={K27_7,buffer[63:40]};
							sel2<=1'b0;
							first<=1'b1;
						end
					end
					else 
					begin
						if(!sel2)
						begin
							{data_1,data_2,data_3,data_4}<=buffer[39:8];
							sel2<=1'b1;
						end
						else
						begin
							{data_1,data_2,data_3,data_4}<={buffer[7:0],buffer[63:40]};
							sel2<=1'b0;
						end
					end
				end
				else // last TLP or DLLP data to be sent
				begin
					if(nullified_TLP_sent) 
					begin
						if(!sel2)
						begin
							{data_1,data_2,data_3,data_4}<={buffer[39:16],K30_7};
							sel2<=1'b0;
						end
						else
						begin
							{data_1,data_2,data_3,data_4}<={buffer[7:0],buffer[63:48],K30_7};
							sel2<=1'b0;
						end	
					end
					else
					begin
						if(!sel2)
						begin
							{data_1,data_2,data_3,data_4}<={buffer[39:16],K29_7};
							sel2<=1'b0;
						end
						else
						begin
							{data_1,data_2,data_3,data_4}<={buffer[7:0],buffer[63:48],K29_7};
							sel2<=1'b0;
						end
					end
				end
			end
			else
			begin
				{data_1,data_2,data_3,data_4}<=32'h0;
				sel2<=sel2;
				first<=1'b0;
			end
		end
		else if(buffer_en_LTSSM==1'b1||buffer[15:0]!=16'h0) // for storing and sending data from LTSSM
		begin
			if(buffer_en_LTSSM)
			begin
				buffer<=data_in_LTSSM;
				{data_1,data_2,data_3,data_4}<=32'h0;
			end
			
			else 
			begin
				if(buffer[15:0]!=16'h0)
				begin
					case(buffer[23:19])
						5'b10000: // TS1 OS
						begin
							case(os_seq)
							2'b00:
							begin
								{data_1,data_2,data_3,data_4}<={K28_5,buffer[63:40]};
								os_seq<=2'b01;
							end
							2'b01:
							begin
								{data_1,data_2,data_3,data_4}<={buffer[39:24],D10_2,D10_2};
								os_seq<=2'b10;
							end
							2'b10:
							begin
								{data_1,data_2,data_3,data_4}<={D10_2,D10_2,D10_2,D10_2};
								os_seq<=2'b11;
							end
							2'b11:
							begin
								{data_1,data_2,data_3,data_4}<={D10_2,D10_2,D10_2,D10_2};
								os_seq<=2'b00;
								buffer[15:0]<=buffer[15:0]-1'b1;
								
							end
							endcase
						end
						5'b01000: // TS2 OS
						begin
							case(os_seq)
							2'b00:
							begin
								{data_1,data_2,data_3,data_4}<={K28_5,buffer[63:40]};
								os_seq<=2'b01;
							end
							2'b01:
							begin
								{data_1,data_2,data_3,data_4}<={buffer[39:24],D5_2,D5_2};
								os_seq<=2'b10;
							end
							2'b10:
							begin
								{data_1,data_2,data_3,data_4}<={D5_2,D5_2,D5_2,D5_2};
								os_seq<=2'b11;
							end
							2'b11:
							begin
								{data_1,data_2,data_3,data_4}<={D5_2,D5_2,D5_2,D5_2};
								os_seq<=2'b00;
								buffer[15:0]<=buffer[15:0]-1'b1;
							end
							endcase
						end
						5'b00100: // EIOS
						begin
							if(buffer[16]==1'b1)
							begin
								if(os_seq==2'b00)
								begin
									{data_1,data_2,data_3,data_4}<={K28_5,K28_3,K28_3,K28_3};
									os_seq<=2'b11;
								end
								else
								begin
									{data_1,data_2,data_3,data_4}<={K28_5,K28_3,K28_3,K28_3};
									buffer[15:0]<=buffer[15:0]-1'b1;
									os_seq<=2'b00;
								end
							end
							else
							begin
								{data_1,data_2,data_3,data_4}<={K28_5,K28_3,K28_3,K28_3};
								buffer[15:0]<=buffer[15:0]-1'b1;
							end
						end
						5'b00010: // EIEOS
						begin
							case(os_seq)
								2'b00:
								begin
									{data_1,data_2,data_3,data_4}<={K28_5,K28_7,K28_7,K28_7};
									os_seq<=2'b01;
								end
								2'b01:
								begin
									{data_1,data_2,data_3,data_4}<={K28_7,K28_7,K28_7,K28_7};
									os_seq<=2'b10;
								end
								2'b10:
								begin
									{data_1,data_2,data_3,data_4}<={K28_7,K28_7,K28_7,K28_7};
									os_seq<=2'b11;
								end
								2'b11:
								begin
									{data_1,data_2,data_3,data_4}<={K28_7,K28_7,K28_7,D10_2};
									os_seq<=2'b00;
									buffer[15:0]<=buffer[15:0]-1'b1;
								end
								endcase
						end
						5'b00001: //FTS
						begin
								if(first==1'b0 && buffer[16]==1)
							begin
								{data_1,data_2,data_3,data_4}<={K28_7,K28_7,K28_7,K28_7};
								first<=1'b1;
							end
							else
							begin
								{data_1,data_2,data_3,data_4}<={K28_5,K28_1,K28_1,K28_1};
								buffer[15:0]<=buffer[15:0]-1'b1;
							end
						end
						default:
						begin
							{data_1,data_2,data_3,data_4}<=32'h0;
							first<=1'b0;
							os_seq<=2'b00;
							buffer<=32'h0;
						end
					endcase
				end
				else
				begin
					data_1<=8'h0;
					data_2<=8'h0;
					data_3<=8'h0;
					data_4<=8'h0;
					first<=1'b0;
					os_seq<=2'b00;
				end
			end
		end
		
		else
		begin
			buffer<=64'h0;
			data_1<=8'h0;
			data_2<=8'h0;
			data_3<=8'h0;
			data_4<=8'h0;
			first<=1'b0;
			sel1<=1'b0;
			sel2<=1'b0;
			os_seq<=2'b00;
		end
	end
end
endmodule