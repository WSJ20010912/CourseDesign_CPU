/*算术逻辑单元*/
module alu(alus,ac,bus,dout);
input [6:0]alus;
input [7:0] ac;
input [15:0] bus;
output [7:0] dout;
reg [7:0] dout;
always@(alus or ac or bus)
begin  
	if(alus==7'd1)//add1 ac+R->ac  其中R->bus->alu
		dout=ac+bus[7:0];
	else if(alus==7'd2)
	   dout=ac-bus[7:0];
	else if(alus==7'd3)
	   dout=ac&bus[7:0];
	else if(alus==7'd4)
	   dout=ac|bus[7:0];
	else if(alus==7'd5)
	   dout=ac^bus[7:0];
	else if(alus==7'd6)
	   dout=ac+8'd1;
	else if(alus==7'd7)
	   dout=8'd0;
	else if(alus==7'd8)
	   dout=~ac;
	else if(alus==7'd9)
	   dout=bus[7:0];
	else
	   dout=8'bxxxxxxxx;
end
endmodule
