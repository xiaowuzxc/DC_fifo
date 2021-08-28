
`timescale 1ns/1ns
module tb_fifo_async (); /* this is automatically generated */
	parameter DSIZE = 8;
	parameter ASIZE = 5;
	logic             rst_n;
	logic [DSIZE-1:0] wdata;
	logic             w_en;
	logic             w_full;
	logic [ASIZE-1:0] wuse;
	logic [DSIZE-1:0] rdata;
	logic             r_empty;
	logic             r_en;
	logic             r_ok;
	logic [ASIZE-1:0] ruse;
	// clock
	logic wclk,rclk;
	initial begin
		wclk = '0;
		rclk = '0;
		#1;
		forever #(5) wclk = ~wclk;
	end
	initial
	begin
		#2;
		forever #(3) rclk = ~rclk;
	end

	//rst
	initial
	begin
		#20;
		rst_n='0;
		w_en='0;
		r_en='0;
		#20;
		rst_n ='1;#20;
		w_en='1;
		r_en='1;
		#100;
		r_en='0;
		#400;
		w_en='0;
		r_en='1;
		#400;
		$finish;
	end
	logic [ASIZE-1:0]i;
	always @(posedge wclk) begin
		if(~rst_n) 
			i <= 0;
		else 
		begin
			i <= i+1;
			wdata <= i;
		end
	end
	// (*NOTE*) replace reset, clock, others
/*
    input  wire             rst_n,//低电平复位
    input  wire             wclk,//写时钟
    input  wire [DSIZE-1:0] wdata,//写数据
    input  wire             w_en,//写使能，1有效
    output wire             w_full,//写满信号，1有效，组合逻辑输出
    output reg  [ASIZE-1:0] wuse,//写域fifo已使用空间  

    input  wire             rclk,//读时钟
    output wire [DSIZE-1:0] rdata,//读数据
    output wire             r_empty,//读空信号，1有效，组合逻辑输出
    input  wire             r_en,//读使能，1有效
    output reg              r_ok,//可读信号，1有效，读使能且非空
    output reg  [ASIZE-1:0] ruse//读域fifo已使用空间
*/


	fifo_async #(
			.DSIZE(DSIZE),
			.ASIZE(ASIZE)
		) inst_fifo_async (
			.rst_n   (rst_n),
			.wclk    (wclk),
			.wdata   (wdata),
			.w_en    (w_en),
			.w_full  (w_full),
			.wuse    (wuse),
			.rclk    (rclk),
			.rdata   (rdata),
			.r_empty (r_empty),
			.r_en    (r_en),
			.r_ok    (r_ok),
			.ruse    (ruse)
		);

//----------------------------------
//产生名为tb.fsdb的文件
//----------------------------------
initial	begin
	    $fsdbDumpfile("tb.fsdb");	    
        $fsdbDumpvars;
end
endmodule
