/*数据暂存器,处理双字节指令时使用，用来存储低八位的地址或数值*/
module tr(din, clk,rst, trload, dout);
input  clk, rst, trload;
input [7:0] din;
output [7:0]dout;
reg [7:0] dout;
always @(posedge clk or negedge rst)
	if(rst==0)
		dout<=0;
	else if(trload)
		dout<=din;
endmodule