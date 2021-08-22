// This is a simple example.
// You can make a your own header file and set its path to settings.
// (Preferences > Package Settings > Verilog Gadget > Settings - User)
//
//      "header": "Packages/Verilog Gadget/template/verilog_header.v"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2014-2021 All rights reserved
// -----------------------------------------------------------------------------
// Author : xiaowuzxc xiaowuzxc@outlook.com
// File   : stream_async_fifo.sv
// Create : 2021-08-20 17:13:56
// Revise : 2021-08-20 17:13:56
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------
`timescale 1ns/1ns
module fifo_async #(
    parameter   DSIZE = 8,//fifo宽度
    parameter   ASIZE = 10//fifo深度
)
(
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
);

reg  [DSIZE-1:0] buffer [1<<ASIZE：1];  // 让综合器自己综合真双端RAM

reg [ASIZE:0] wptr,//写指针 
wq_wptr_grey, //写指针格雷码，写时钟打1拍
rq1_wptr_grey, //写指针格雷码，读时钟打1拍
rq2_wptr_grey,//写指针格雷码，读时钟打2拍
w2rptr;//二进制写指针，读时钟域的
wire [ASIZE:0]wptr_grey;//写指针格雷码

reg [ASIZE:0] rptr, //读指针

rq_rptr_grey, //读指针格雷码，读时钟打1拍
wq1_rptr_grey, //读指针格雷码，写时钟打1拍
wq2_rptr_grey, //读指针格雷码，写时钟打2拍
r2wptr;//二进制读指针，写时钟域的
wire [ASIZE:0]rptr_grey; //读指针格雷码

assign wptr_grey = (wptr >> 1) ^ wptr;//二进制写指针转格雷码
integer i;
always @ (wq2_rptr_grey)//读指针格雷码转写域读指针
begin    
    r2wptr[ASIZE-1]=wq2_rptr_grey[ASIZE-1];    
    for(i=ASIZE-2;i>=0;i=i-1)        
        r2wptr[i]=r2wptr[i+1]^wq2_rptr_grey[i];
end


assign rptr_grey = (rptr >> 1) ^ rptr;//二进制读指针转格雷码
integer j;
always @ (rq2_wptr_grey)//写指针格雷码转读域写指针
begin    
    w2rptr[ASIZE-1]=rq2_wptr_grey[ASIZE-1];    
    for(j=ASIZE-2;j>=0;j=j-1)        
        w2rptr[j]=w2rptr[j+1]^rq2_wptr_grey[j];
end
//----------------写指针跨时钟域-------------//
always @ (posedge wclk or negedge rst_n)
    if(~rst_n)
        wq_wptr_grey <= 0;
    else
        wq_wptr_grey <= wptr_grey;
always @ (posedge rclk or negedge rst_n)
    if(~rst_n)
        rq1_wptr_grey <= 0;
    else
        rq1_wptr_grey <= wq_wptr_grey;
always @ (posedge rclk or negedge rst_n)
    if(~rst_n)
        rq2_wptr_grey <= 0;
    else
        rq2_wptr_grey <= rq1_wptr_grey;
//----------------写指针跨时钟域-------------//
//----------------读指针跨时钟域-------------//
always @ (posedge rclk or negedge rst_n)
    if(~rst_n)
        rq_rptr_grey <= 0;
    else
        rq_rptr_grey <= rptr_grey;
always @ (posedge wclk or negedge rst_n)
    if(~rst_n)
        wq1_rptr_grey <= 0;
    else
        wq1_rptr_grey <= rq_rptr_grey;
always @ (posedge wclk or negedge rst_n)
    if(~rst_n)
        wq2_rptr_grey <= 0;
    else
        wq2_rptr_grey <= wq1_rptr_grey;
//----------------读指针跨时钟域-------------//

assign w_full  = wq2_rptr_grey == {~wptr_grey[ASIZE:ASIZE-1], wptr_grey[ASIZE-2:0]};//写满判断，指针绕了一圈，最高位不同
assign r_empty = rq2_wptr_grey == rptr_grey;//读空判断

//assign itready = rst_n & ~w_full;

always @ (posedge wclk or negedge rst_n)
    if(~rst_n) //异步复位
        wptr <= 0;
    else 
    begin
        if(w_en & ~w_full)
            wptr <= wptr + 1;//写指针++
    end

always @ (posedge wclk)
    if(w_en & ~w_full)
        buffer[wptr[ASIZE-1:0]] <= wdata;//写数据

//----------读判断+数据输出+指针移动------------//
wire            rdready = ~r_ok | r_en;
reg             rdack;
reg [DSIZE-1:0] rddata;
reg [DSIZE-1:0] keepdata;
assign rdata = rdack ? rddata : keepdata;

always @ (posedge rclk or negedge rst_n)
    if(~rst_n) //异步复位
    begin
        r_ok <= 1'b0;
        rdack <= 1'b0;
        rptr <= 0;
        keepdata <= 0;
    end 
    else 
    begin
        r_ok <= ~r_empty | ~rdready;//可读判断
        rdack <= ~r_empty & rdready;//是否读取
        if(~r_empty & rdready)
            rptr <= rptr + 1;//读完地址++
        if(rdack)
            keepdata <= rddata;//不读，保持上一次数据
    end

always @ (posedge rclk)
    rddata <= buffer[rptr[ASIZE-1:0]];//输出数据
//----------读判断+数据输出+指针移动------------//

//--------------写域fifo已使用空间------------
always @ (posedge wclk or negedge rst_n)
    if(~rst_n)
        wuse <= 0;
    else
        wuse <= wptr-r2wptr;
//--------------读域fifo已使用空间------------
always @ (posedge rclk or negedge rst_n)
    if(~rst_n)
        ruse <= 0;
    else
        ruse <= w2rptr-rptr;
endmodule
