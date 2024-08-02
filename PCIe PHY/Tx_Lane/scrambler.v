/*

Credits:
Design, Simulation and Implementation of PCI Express 2.0 Physical Layer on FPGA
By: Shivani Hukare

modifications done to comply with rules in PCI Express 2.0 for k-codes, SKP,COM symbol and data in TS OS

rules for scram_en-
scram_en is always 1 by default,
scram_en is 0 in loopback slave
scram_en is 0 only at end of configuration
*/

module scrambler
(
input rst,
input clk,
input is_kcode, // used since some k-codes and d-codes share same values
input data_in_TS_OS, // data in TS OS is not scrambled
input scram_en,
input [7:0] data_in, 
output [7:0]data_out
);

// COM is for lfsr initialisation and for symbol alignment
// SKP is used for synchronisation
reg [7:0]data_out_reg;
reg [15:0]lfsr_next;
reg [15:0] lfsr_current;
parameter 
SKP=8'h1C,// SKP symbol, not to have delay in LFSR hence we don't advance LFSR by 8 serial clocks
COM=8'hBC; // COM Symbol initialises LFSR

assign data_out=data_out_reg;

always @(*) 

begin
		lfsr_next[0] = lfsr_current[8];
		lfsr_next[1] = lfsr_current[9];
		lfsr_next[2] = lfsr_current[10];
		lfsr_next[3] = lfsr_current[8] ^ lfsr_current[11];
		lfsr_next[4] = lfsr_current[8] ^ lfsr_current[9] ^ lfsr_current[12];
		lfsr_next[5] = lfsr_current[8] ^ lfsr_current[9] ^ lfsr_current[10] ^ lfsr_current[13];
		lfsr_next[6] = lfsr_current[9] ^ lfsr_current[10] ^ lfsr_current[11] ^ lfsr_current[14];
		lfsr_next[7] = lfsr_current[10] ^ lfsr_current[11] ^ lfsr_current[12] ^ lfsr_current[15];
		lfsr_next[8] = lfsr_current[0] ^ lfsr_current[11] ^ lfsr_current[12] ^ lfsr_current[13];
		lfsr_next[9] = lfsr_current[1] ^ lfsr_current[12] ^ lfsr_current[13] ^ lfsr_current[14];
		lfsr_next[10] = lfsr_current[2] ^ lfsr_current[13] ^ lfsr_current[14] ^ lfsr_current[15];
		lfsr_next[11] = lfsr_current[3] ^ lfsr_current[14] ^ lfsr_current[15];
		lfsr_next[12] = lfsr_current[4] ^ lfsr_current[15];
		lfsr_next[13] = lfsr_current[5];
		lfsr_next[14] = lfsr_current[6];
		lfsr_next[15] = lfsr_current[7];
	
		
	end
  

always @(posedge clk, negedge rst) 
begin
   if(!rst) 
	begin
      lfsr_current <= {16{1'b1}};
      data_out_reg <= {8{1'b0}};
	end
	
   else 
	begin
		if(scram_en)
		begin
		if(is_kcode==1'b0 && data_in_TS_OS==1'b0) // data is a kcode or is in TS1/TS2 OS, pass without scrambling
		begin	
			data_out_reg[0] = data_in[0] ^ lfsr_current[15];
			data_out_reg[1] = data_in[1] ^ lfsr_current[14];
			data_out_reg[2] = data_in[2] ^ lfsr_current[13];
			data_out_reg[3] = data_in[3] ^ lfsr_current[12];
			data_out_reg[4] = data_in[4] ^ lfsr_current[11];
			data_out_reg[5] = data_in[5] ^ lfsr_current[10];
			data_out_reg[6] = data_in[6] ^ lfsr_current[9];
			data_out_reg[7] = data_in[7] ^ lfsr_current[8];
		end
		else 		// scramble data
			data_out_reg<=data_in;
		
		if(is_kcode==1'b1&&data_in==COM) // if COM is passed, LFSR is initialised
			lfsr_current ={16{1'b1}};
		else if(is_kcode==1'b1 &&data_in==SKP)// if SKP is passed , don't advance LFSR
			lfsr_current=lfsr_current;
		else // advance lfsr by 8 serial clocks
		begin
			lfsr_current=lfsr_next;
		end
			
		
		end
		else
		begin
		data_out_reg=data_out_reg;
		end
	end
end
	

endmodule
