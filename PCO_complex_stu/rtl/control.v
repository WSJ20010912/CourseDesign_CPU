/*组合逻辑控制单元，根据时钟生成为控制信号和内部信号*/
/*
输入：
       din：指令，8位，来自IR；
       clk：时钟信号，1位，上升沿有效；
       rst：复位信号，1位，与cpustate共同组成reset信号；
       cpustate：当前CPU的状态（IN，CHECK，RUN），2位；
       z：零标志，1位，零标志寄存器的输出，如果指令中涉及到z，可加上，否则可去掉；
输出：
      clr：清零控制信号
     自行设计的各个控制信号
*/
//省略号中是自行设计的控制信号，需要自行补充，没用到z的话也可去掉z
module control(din,clk,rst,z,cpustate,read,write,membus,busmem,arload,arinc,pcload,pcinc,pcbus,
drload,drbus,trload,trbus,irload,rload,rbus,alus,zload,acload,acbus,drhbus,drlbus,clr);
input [7:0]din;
input clk;
input rst,z;
input [1:0] cpustate;
output read,write,membus,busmem,arload,arinc,pcload,pcinc,pcbus,drload,drbus,
trload,trbus,irload,rload,rbus,zload,acload,acbus,drhbus,drlbus,clr;
output [6:0] alus;

//parameter's define
/*-------*/
wire reset;
/*-------*/
//在下方加上自行定义的状态
wire fetch1,fetch2,fetch3,nop1;
wire add1,sub1,and1,or1,xor1;
wire inac1,clac1,not1;
wire movr1,movac1;
wire ldac1,ldac2,ldac3,ldac4,ldac5, stac1,stac2,stac3,stac4,stac5;
wire jump1,jump2,jump3, jmpz1,jmpz2,jmpz3, jpnz1,jpnz2,jpnz3;

reg inop,iadd,isub,iand,ior,ixor,iinac,iclac,inot,imovr,imovac,ildac,istac,ijump,ijmpz,ijpnz;


//时钟节拍，8个为一个指令周期，t0-t2分别对应fetch1-fetch3，t3-t7分别对应各指令的执行周期，当然不是所有指令都需要5个节拍的。例如add指令只需要一个t3
reg t0,t1,t2,t3,t4,t5,t6,t7; 

// signals for the counter, 内部信号：clr清零，inc自增
wire clr;
wire inc;
assign reset = rst&(cpustate == 2'b11);

//clr信号是每条指令执行完毕后必做的清零，下面赋值语句要修改，需要“或”各指令的最后一个周期
assign clr=nop1||add1||sub1||and1||or1||xor1||inac1||clac1||not1||movr1||movac1||ldac5||stac5||jump3||jmpz3||jpnz3;
assign inc=~clr;
	
//generate the control signal using state information
//取公共指令过程
assign fetch1=t0;
assign fetch2=t1;
assign fetch3=t2;
//什么都不做的译码
assign nop1=inop&&t3;//inop表示nop指令，nop1是nop指令的执行周期的第一个状态也是最后一个状态，因为只需要1个节拍t3完成

assign ldac1=ildac&&t3;
assign ldac2=ildac&&t4;
assign ldac3=ildac&&t5;
assign ldac4=ildac&&t6;
assign ldac5=ildac&&t7;

assign stac1=istac&&t3;
assign stac2=istac&&t4;
assign stac3=istac&&t5;
assign stac4=istac&&t6;
assign stac5=istac&&t7;

assign movr1=imovr&&t3;
assign movac1=imovac&&t3;

assign jump1=ijump&&t3;
assign jump2=ijump&&t4;
assign jump3=ijump&&t5;

assign jmpz1=ijmpz&&t3;
assign jmpz2=ijmpz&&t4;
assign jmpz3=ijmpz&&t5;

assign jpnz1=ijpnz&&t3;
assign jpnz2=ijpnz&&t4;
assign jpnz3=ijpnz&&t5;

assign add1=iadd&&t3;
assign sub1=isub&&t3;
assign inac1=iinac&&t3;
assign clac1=iclac&&t3;
assign and1=iand&&t3;
assign or1=ior&&t3;
assign xor1=ixor&&t3;
assign not1=inot&&t3;
//以下写出各条指令状态的表达式

/*
        T0    Fetch1  AR<—PC                          pcbus、arload
        T1    Fetch2  DR<—M，PC<—PC+1                      read、membus、drload、pcinc
        T2    Fetch3  IR<—DR，AR<—PC                      irload、pcbus、arload


0  NOP  00000000  T3  NOP

1  LDAC  00000001 T3  LDAC1  DR <- M, PC <- PC + 1, AR <- AR + 1        read、membus、drload、pcinc、arinc
            T4  LDAC2  TR <- DR, DR <- M, PC <- PC + 1          trload、read、membus、drload、pcinc
            T5  LDAC3  AR <- DR, TR                      drhbus、trbus、arload
            T6  LDAC4  DR <- M                          read、membus、drload
            T7  LDAC5  AC <- DR                          drlbus、acload、alus
            
2  STAC  00000010 T3  STAC1  DR <- M, PC <- PC + 1, AR <- AR + 1        read、membus、drload、pcinc、arinc
            T4  STAC2  TR <- DR, DR <- M, PC <- PC + 1          trload、read、membus、drload、pcinc
            T5  STAC3  AR <- DR, TR                      drhbus、trbus、arload
            T6  STAC4  DR <- AC                          drload、acbus
            T7  STAC5  M <- DR                          write、busmem、drlbus
            
3  MOVAC  00000011  T3  MOVAC1  R <- AC                        acbus、rload

4  MOVR  00000100  T3  MOVR1  AC <- R                          rbus、acload、alus

5  JUMP  00000101 T3  JUMP1  DR <- M, AR <- AR + 1                read、membus、drload、arinc
            T4  JUMP2  TR <- DR, DR <- M                    trload、read、membus、drload
            T5  JUMP3  PC <- DR, TR                      drhbus、trbus、pcload
            
6  JMPZ  00000110 T3  JMPZ1  DR <- M, AR <- AR + 1                read、membus、drload、arinc
            T4  JMPZ2  TR <- DR, DR <- M                    trload、read、membus、drload
            T5  JMPZ3  PC <- DR, TR                      drhbus、trbus、pcload
            如果没有跳转，pcinc+2(jmpz2,jmpz3)
            
7  JPNZ  00000111 T3  JPNZ1  DR <- M, AR <- AR + 1                read、membus、drload、arinc
            T4  JPNZ2  TR <- DR, DR <- M                    trload、read、membus、drload
            T5  JPNZ3  PC <- DR, TR                      drhbus、trbus、pcload
            如果没有跳转，pcinc+2(jpnz2,jpnz3)
            
8  ADD  00001000  T3  ADD1  AC <- AC + R                      rbus、alus、acload、zload

9  SUB  00001001  T3  SUB1  AC <- AC - R                      rbus、alus、acload、zload

10  INAC  00001010  T3  INAC1  AC <- AC + 1                      alus、acload、zload

11  CLAC  00001011  T3  CLAC1  AC <- 0                          alus、acload、zload

12  AND  00001100  T3  AND1  AC <- AC & R                      rbus、alus、acload、zload

13  OR    00001101  T3  OR1  AC <- AC | R                      rbus、alus、acload、zload

14  XOR  00001110  T3  XOR1  AC <- AC ^ R                      rbus、alus、acload、zload

15  NOT  00001111  T3  NOT1  AC <- ~AC                        alus、acload、zload
*/
assign pcbus=fetch1||fetch3;
assign pcload=jump3||(z&&jmpz3)||(!z&&jpnz3);
assign write=stac5;
assign read=fetch2||ldac1||stac1||ldac2||stac2||ldac4||jump1||(z&&jmpz1)||(!z&&jpnz1)||jump2||(z&&jmpz2)||(!z&&jpnz2);
assign membus=fetch2||ldac1||stac1||ldac2||stac2||ldac4||jump1||(z&&jmpz1)||(!z&&jpnz1)||jump2||(z&&jmpz2)||(!z&&jpnz2);
assign busmem=stac5;
assign arload=fetch1||fetch3||ldac3||stac3;
assign arinc=ldac1||stac1||jump1||(z&&jmpz1)||(!z&&jpnz1);
assign pcinc=fetch2||ldac1||stac1||ldac2||stac2||(!z&&jmpz2)||(!z&&jmpz3)||(z&&jpnz2)||(z&&jpnz3);
assign irload=fetch3;
assign rload=movac1;
assign rbus=add1||sub1||and1||or1||xor1||movr1;
assign acbus=movac1||stac4;
assign acload=add1||sub1||and1||or1||xor1||inac1||clac1||not1||movr1||ldac5;
assign zload=add1||sub1||and1||or1||xor1||inac1||clac1||not1;
assign trload=ldac2||stac2||jump2||(z&&jmpz2)||(!z&&jpnz2);
assign trbus=ldac3||stac3||jump3||(z&&jmpz3)||(!z&&jpnz3);
assign drload=fetch2||ldac1||stac1||ldac2||stac2||ldac4||stac4	||jump1||(z&&jmpz1)||(!z&&jpnz1)||jump2||(z&&jmpz2)||(!z&&jpnz2);
assign drhbus=ldac3||stac3||jump3||(z&&jmpz3)||(!z&&jpnz3);
assign drlbus=ldac5||stac5;

//alus
reg [6:0] alus;
always@(add1 or sub1 or and1 or or1 or xor1  or inac1 or clac1 or not1 or movr1 or ldac5)
begin
   if(add1)
		alus=7'd1;
	else if(sub1)
		alus=7'd2;
	else if(and1)
		alus=7'd3;
	else if(or1)
		alus=7'd4;
	else if(xor1)
		alus=7'd5;
	else if(inac1)
		alus=7'd6;
	else if(clac1)
		alus=7'd7;
	else if(not1)
		alus=7'd8;
	else if(ldac5||movr1)
		alus=7'd9;
	else
		alus=7'bxxxxxxx;
end

always@(posedge clk or negedge reset)
begin
if(!reset)
	begin//各指令清零，以下已为nop指令清零，请补充其他指令，为其他指令清零
		inop<=0;
		ildac<=0;
		istac<=0;
		imovac<=0;
		imovr<=0;
		ijump<=0;
		ijmpz<=0;
		ijpnz<=0;
		iadd<=0;
		isub<=0;
		iinac<=0;
		iclac<=0;
		iand<=0;
		ior<=0;
		ixor<=0;
		inot<=0;
	end
else 
begin
	//alus初始化为x，加上将alus初始化为x的语句，后续根据不同指令为alus赋值
	if(din[7:4]==0000)//译码处理过程
	begin
		case(din[3:0])
		0:  begin//指令低4位为0，应该是nop指令，因此这里inop的值是1，而其他指令应该清零，请补充为其他指令清零的语句
			inop<=1;
			ildac<=0;
			istac<=0;
			imovac<=0;
			imovr<=0;
			ijump<=0;
			ijmpz<=0;
			ijpnz<=0;
			iadd<=0;
			isub<=0;
			iinac<=0;
			iclac<=0;
			iand<=0;
			ior<=0;
			ixor<=0;
			inot<=0;
			end
		1:  begin
			//指令低4位为0001，应该是ildac指令，因此ildac指令为1，其他指令都应该是0。
			//该指令需要做一个加0运算，详见《示例机的设计Quartus II和使用说明文档》中“ALU的设计”，因此这里要对alus赋值
			//后续各分支类似，只有一条指令为1，其他指令为0，以下分支都给出nop指令的赋值，需要补充其他指令，注意涉及到运算的都要对alus赋值
			inop<=0;
			ildac<=1;
			istac<=0;
			imovac<=0;
			imovr<=0;
			ijump<=0;
			ijmpz<=0;
			ijpnz<=0;
			iadd<=0;
			isub<=0;
			iinac<=0;
			iclac<=0;
			iand<=0;
			ior<=0;
			ixor<=0;
			inot<=0;
			end
		2:  begin
			inop<=0;
			ildac<=0;
			istac<=1;
			imovac<=0;
			imovr<=0;
			ijump<=0;
			ijmpz<=0;
			ijpnz<=0;
			iadd<=0;
			isub<=0;
			iinac<=0;
			iclac<=0;
			iand<=0;
			ior<=0;
			ixor<=0;
			inot<=0;
			end
		3:  begin
			inop<=0;
			ildac<=0;
			istac<=0;
			imovac<=1;
			imovr<=0;
			ijump<=0;
			ijmpz<=0;
			ijpnz<=0;
			iadd<=0;
			isub<=0;
			iinac<=0;
			iclac<=0;
			iand<=0;
			ior<=0;
			ixor<=0;
			inot<=0;
			end
		4:  begin
			inop<=0;
			ildac<=0;
			istac<=0;
			imovac<=0;
			imovr<=1;
			ijump<=0;
			ijmpz<=0;
			ijpnz<=0;
			iadd<=0;
			isub<=0;
			iinac<=0;
			iclac<=0;
			iand<=0;
			ior<=0;
			ixor<=0;
			inot<=0;
			end
		5:  begin
			inop<=0;
			ildac<=0;
			istac<=0;
			imovac<=0;
			imovr<=0;
			ijump<=1;
			ijmpz<=0;
			ijpnz<=0;
			iadd<=0;
			isub<=0;
			iinac<=0;
			iclac<=0;
			iand<=0;
			ior<=0;
			ixor<=0;
			inot<=0;
			end
		6:	begin
			inop<=0;
			ildac<=0;
			istac<=0;
			imovac<=0;
			imovr<=0;
			ijump<=0;
			ijmpz<=1;
			ijpnz<=0;
			iadd<=0;
			isub<=0;
			iinac<=0;
			iclac<=0;
			iand<=0;
			ior<=0;
			ixor<=0;
			inot<=0;
			end
		7:	begin
			inop<=0;
			ildac<=0;
			istac<=0;
			imovac<=0;
			imovr<=0;
			ijump<=0;
			ijmpz<=0;
			ijpnz<=1;
			iadd<=0;
			isub<=0;
			iinac<=0;
			iclac<=0;
			iand<=0;
			ior<=0;
			ixor<=0;
			inot<=0;
			end
		8:	begin
			inop<=0;
			ildac<=0;
			istac<=0;
			imovac<=0;
			imovr<=0;
			ijump<=0;
			ijmpz<=0;
			ijpnz<=0;
			iadd<=1;
			isub<=0;
			iinac<=0;
			iclac<=0;
			iand<=0;
			ior<=0;
			ixor<=0;
			inot<=0;
			end
		9:	begin
			inop<=0;
			ildac<=0;
			istac<=0;
			imovac<=0;
			imovr<=0;
			ijump<=0;
			ijmpz<=0;
			ijpnz<=0;
			iadd<=0;
			isub<=1;
			iinac<=0;
			iclac<=0;
			iand<=0;
			ior<=0;
			ixor<=0;
			inot<=0;
			end
		10:begin
			inop<=0;
			ildac<=0;
			istac<=0;
			imovac<=0;
			imovr<=0;
			ijump<=0;
			ijmpz<=0;
			ijpnz<=0;
			iadd<=0;
			isub<=0;
			iinac<=1;
			iclac<=0;
			iand<=0;
			ior<=0;
			ixor<=0;
			inot<=0;
			end
		11:begin
			inop<=0;
			ildac<=0;
			istac<=0;
			imovac<=0;
			imovr<=0;
			ijump<=0;
			ijmpz<=0;
			ijpnz<=0;
			iadd<=0;
			isub<=0;
			iinac<=0;
			iclac<=1;
			iand<=0;
			ior<=0;
			ixor<=0;
			inot<=0;
			end
		12:begin
			inop<=0;
			ildac<=0;
			istac<=0;
			imovac<=0;
			imovr<=0;
			ijump<=0;
			ijmpz<=0;
			ijpnz<=0;
			iadd<=0;
			isub<=0;
			iinac<=0;
			iclac<=0;
			iand<=1;
			ior<=0;
			ixor<=0;
			inot<=0;
			end
		13:begin
			inop<=0;
			ildac<=0;
			istac<=0;
			imovac<=0;
			imovr<=0;
			ijump<=0;
			ijmpz<=0;
			ijpnz<=0;
			iadd<=0;
			isub<=0;
			iinac<=0;
			iclac<=0;
			iand<=0;
			ior<=1;
			ixor<=0;
			inot<=0;
			end
		14:begin
			inop<=0;
			ildac<=0;
			istac<=0;
			imovac<=0;
			imovr<=0;
			ijump<=0;
			ijmpz<=0;
			ijpnz<=0;
			iadd<=0;
			isub<=0;
			iinac<=0;
			iclac<=0;
			iand<=0;
			ior<=0;
			ixor<=1;
			inot<=0;
			end
		15:begin
			inop<=0;
			ildac<=0;
			istac<=0;
			imovac<=0;
			imovr<=0;
			ijump<=0;
			ijmpz<=0;
			ijpnz<=0;
			iadd<=0;
			isub<=0;
			iinac<=0;
			iclac<=0;
			iand<=0;
			ior<=0;
			ixor<=0;
			inot<=1;
			end
		//如果还有分支，可以继续写，如果没有分支了，写上defuault语句
		default:begin
			inop<=0;
			ildac<=0;
			istac<=0;
			imovac<=0;
			imovr<=0;
			ijump<=0;
			ijmpz<=0;
			ijpnz<=0;
			iadd<=0;
			isub<=0;
			iinac<=0;
			iclac<=0;
			iand<=0;
			ior<=0;
			ixor<=0;
			inot<=0;
			end
		endcase
	end
end
end

/*——————8个节拍t0-t7————*/
always @(posedge clk or negedge reset)
begin
if(!reset) //reset清零
begin
	t0<=1;
	t1<=0;
	t2<=0;
	t3<=0;
	t4<=0;
	t5<=0;
	t6<=0;
	t7<=0;
end
else
begin
	if(inc) //运行
	begin
	t7<=t6;
	t6<=t5;
	t5<=t4;
	t4<=t3;
	t3<=t2;
	t2<=t1;
	t1<=t0;
	t0<=0;
	end
	else if(clr) //清零
	begin
	t0<=1;
	t1<=0;
	t2<=0;
	t3<=0;
	t4<=0;
	t5<=0;
	t6<=0;
	t7<=0;
	end
end

end
/*—————结束—————*/
endmodule
	
		