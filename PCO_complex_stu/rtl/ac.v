/*AC通用寄存器，存储第一个操作数*/
module ac(din, clk, rst,acload, dout);
input  clk, rst, acload;
input [7:0] din;
output [7:0]dout;

reg [7:0] dout;
always @(posedge clk or negedge rst)
	if(rst==0)
		dout<=0;
	else if(acload)
		dout<=din;
endmodule
