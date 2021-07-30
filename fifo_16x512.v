
module fifo_16x512 (//16bit*2048
	input aclr,
	input [kuan-1:0] data,//wrclk，写数据
	input rdclk,//读时钟
	input rdreq,//rdclk，1读使能
	input wrclk,//写时钟
	input wrreq,//wrclk，1写使能
	output reg [kuan-1:0]q,//rdclk，读数据
	output reg rdempty,//rdclk，1读空
	output reg [shenbit-1:0]rdusedw,//rdclk，读端fifo内容计数
	output reg wrfull,//wrclk，1写满
	output reg [shenbit-1:0]wrusedw//wrclk，写端fifo内容计数
	);
parameter kuan=16;//fifo宽度
parameter shenbit=11;//2**shenbit=深度
parameter shen=2**shenbit;//fifo深度
reg [kuan-1:0]fifo_reg[shen-1:0];//FIFO寄存器
reg [shenbit-1:0]r_addr,//读端口fifo地址
	r2w0,//打一拍
	r2w1;//读地址同步至写端
reg [shenbit-1:0]w_addr,//写端口fifo地址
	w2r0,//打一拍
	w2r1;//写地址同步至读端
//写端fifo控制器
always @(posedge wrclk or negedge aclr)
begin
	if(~aclr)
	begin
		fifo_reg[0]<=0;//fifo第一个寄存器复位
		w_addr<=0;//fifo第一个寄存器复位
		r2w0<=0;
		r2w1<=0;
		wrusedw<=0;
	end 
	else
	begin
		if (wrreq) //数据写入
		begin
			fifo_reg[w_addr]<=data;
			w_addr<=w_addr+1;//写地址递增
		end
		if (r2w1 == (w_addr+1))//写满判断
			wrfull<=1'b1;
		else
			wrfull<=1'b0;
		r2w0<=r_addr;
		r2w1<=r2w0;//打两拍
		wrusedw<=w_addr-r2w1;//写端fifo内容计数
	end
end
//读端fifo控制器
always @(posedge rdclk or negedge aclr)
begin
	if(~aclr)
	begin
		fifo_reg[0]<=0;//fifo第一个寄存器复位
		r_addr<=0;//fifo第一个寄存器复位
		w2r0<=0;
		w2r1<=0;
		rdusedw<=0;
	end 
	else
	begin
		if (rdreq) //数据读取
		begin
			q<=fifo_reg[r_addr];
			r_addr<=r_addr+1;//读地址递增
		end
		if (w2r1 == r_addr)//读空判断
			rdempty<=1'b1;
		else
			rdempty<=1'b0;
		w2r0<=w_addr;
		w2r1<=w2r0;//打两拍
		rdusedw<=w2r1-r_addr;//读端fifo内容计数
	end
end
endmodule
