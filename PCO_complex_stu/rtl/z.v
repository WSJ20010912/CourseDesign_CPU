/*标志寄存器*/
module z(din,clk,rst,zload,dout);
input  clk, rst, zload;
input [7:0]din;
output dout;
reg dout;
always @(posedge clk or negedge rst)
	if(rst==0)
		dout<=0;
	else if(zload)
		if(din==8'd0)
			dout<=1;
		else
			dout<=0;
endmodule