/*R通用寄存器，用来存放第二个操作数*/
module r(din, clk, rst,rload,  dout);
input  clk, rst, rload;
input [15:0] din;
output [7:0]dout;

reg [7:0] dout;
always @(posedge clk or negedge rst)
	if(rst==0)
		dout<=0;
	else if(rload)
		dout[7:0]<=din[7:0];
endmodule


