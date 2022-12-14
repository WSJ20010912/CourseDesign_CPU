/*CPU*/
//省略号中是自行设计的控制信号，需要自行补充
module cpu(data_in,clk_quick,clk_slow,clk_delay,rst,SW_choose,A1,cpustate,addr,data_out,acdbus,rdbus,
zout,read,write,membus,busmem,arload,arinc,pcload,pcinc,pcbus,drload,drbus,trload,trbus,irload,rload,
rbus,acload,acbus,alus,zload,drhbus,drlbus,clr);
input[7:0] data_in;
input clk_quick,clk_slow,clk_delay;
input rst;
input SW_choose,A1;
input [1:0] cpustate;

output [15:0] addr; 
output [7:0] data_out;
output [7:0] acdbus;//AC寄存器的输出
output [7:0] rdbus;//R寄存器的输出
//补充自行设计的控制信号的端口说明，都是output
output zout,read,write,membus,busmem,arload,arinc,pcload,pcinc,pcbus,drload,drbus,
trload,trbus,irload,rload,rbus,acload,acbus,alus,zload,drhbus,drlbus,clr;

wire[6:0] alus;
wire clk_choose,clk_run;
wire[15:0] dbus,pcdbus;
wire[7:0]drdbus,trdbus,rdbus,acdbus, aludbus;
wire[7:0] irdbus;//ir输出

//定义一些需要的内部信号

//qtsj(clk_quick,clk_slow,clk_delay,clr,rst,SW_choose,A1,cpustate,clk_run,clk_choose);qtsj实例化
qtsj qtdl(.clk_quick(clk_quick),.clk_slow(clk_slow),.clk_delay(clk_delay),.clr(clr),.rst(rst),.SW_choose(SW_choose),
.A1(A1),.cpustate(cpustate),.clk_run(clk_run),.clk_choose(clk_choose));
//ar(din, clk, rst,arload, arinc, dout);ar实例化
ar mar(.din(dbus),.clk(clk_choose),.rst(rst),.arload(arload),.arinc(arinc),.dout(addr));
//pc(din, clk, rst,pcload, pcinc, dout);pc实例化
pc mpc(.din(dbus),.clk(clk_choose),.rst(rst),.pcload(pcload),.pcinc(pcinc),.dout(pcdbus));

//dr(din, clk,rst, drload, dout);补充dr实例化语句
dr mdr(.din(dbus),.clk(clk_choose),.rst(rst),.drload(drload),.dout(drdbus));
//tr(din, clk,rst, trload, dout);补充tr实例化语句，如果需要tr的话
tr mtr(.din(drdbus),.clk(clk_choose),.rst(rst),.trload(trload),.dout(trdbus));

//ir(din,clk,rst,irload,dout);补充ir实例化语句
ir mir(.din(drdbus),.clk(clk_choose),.rst(rst),.irload(irload),.dout(irdbus));

//r(din, clk, rst,rload, dout);补充r实例化语句
r mr(.din(dbus),.clk(clk_choose),.rst(rst),.rload(rload),.dout(rdbus));
//ac(din, clk, rst,acload, dout);补充ac实例化语句
ac mac(.din(aludbus),.clk(clk_choose),.rst(rst),.acload(acload),.dout(acdbus));

//alu(alus,ac, bus, dout);补充alu实例化语句
alu malu(.alus(alus),.ac(acdbus),.bus(dbus),.dout(aludbus));

//z(din,clk,rst, zload,dout);补充z实例化语句，如果需要的话
z mz(.din(aludbus),.clk(clk_choose),.rst(rst),.zload(zload),.dout(zout));

//control(din,clk,rst,z,cpustate,read,...,clr);补充control实例化语句
control mcontrol(.din(irdbus),.clk(clk_run),.rst(rst),.z(zout),.cpustate(cpustate),
.read(read),.write(write),.membus(membus),.busmem(busmem),.arload(arload),.arinc(arinc),.pcload(pcload),
.pcinc(pcinc),.pcbus(pcbus),.drload(drload),.drbus(drbus),.trload(trload),.trbus(trbus),.irload(irload),
.rload(rload),.rbus(rbus),.alus(alus),.zload(zload),.acload(acload),.acbus(acbus),.drhbus(drhbus),.drlbus(drlbus),.clr(clr));

//allocate dbus
assign dbus[15:0]=(pcbus)?pcdbus[15:0]:16'bzzzzzzzzzzzzzzzz;
assign dbus[15:8]=(drhbus)?drdbus[7:0]:8'bzzzzzzzz;
assign dbus[7:0]=(drlbus)?drdbus[7:0]:8'bzzzzzzzz;

////如果需要tr的话，补充dbus接收tr的输出trdbus
assign dbus[7:0]=trbus?trdbus[7:0]:8'bzzzzzzzz;

////如果有存储器-寄存器传送指令，则通过如下方式为ac和r赋值
assign dbus[7:0]=(rbus)?rdbus[7:0]:8'bzzzzzzzz;
assign dbus[7:0]=(acbus)?acdbus[7:0]:8'bzzzzzzzz;

assign dbus[7:0]=(membus)?data_in[7:0]:8'bzzzzzzzz;
assign data_out=(busmem)?dbus[7:0]:8'bzzzzzzzz;


endmodule
