module deserialiser(
input data_in,
input clk,rst,enable,
output [9:0]data_out
);
reg [9:0]data;
reg [3:0]count;
assign data_out=data;

always@(posedge clk or negedge rst)
begin
	if(!rst)
		begin
		data<=10'h000;
		count<=4'h0;
		end
	else
	begin
		if(enable)
		begin
			data[9-count]=data_in;
			count=count+1'b1;
			if(count==10)
				count=4'h0;
			else 
				count=count;
		end
		else
		begin
			data=data;
			count=count;
		end
	end
end

endmodule
