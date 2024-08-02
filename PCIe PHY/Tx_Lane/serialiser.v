module serialiser(
input [0:9] data_in,
input clk,rst,enable,
output out
);
reg Lane_reg;
reg [3:0]count;
assign out=Lane_reg;

always@(posedge clk or negedge rst)
begin
	if(!rst)
		begin
		Lane_reg<=1'h0;
		count<=4'h0;
		end
	else
	begin
		if(enable)
		begin
			Lane_reg=data_in[count];
			count=count+1'b1;
			if(count==10)
				count=4'h0;
			else 
				count=count;
		end
		else
		begin
			Lane_reg=1'b0;
			count=count;
		end
	end
end

endmodule
