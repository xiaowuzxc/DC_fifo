# 异步FIFO的纯verilog实现

#### 介绍
使用verilog编写的异步fifo，读写端口各有一组时钟、读写使能、读写端口、满空指示、fifo使用量。本模块既不可靠，也不成熟，更不实用；注释写得多，可以作为学习参考。

fifo_async.v为源文件，fifo_async.pdf为RTL视图

testbench文件夹中有仿真文件，需要安装VCS，Verdi，cd ./verification后可以使用makefile。make all执行仿真，make clean清理文件。
#### 模块架构
架构说明

rst_n：异步复位，低电平有效

| 写入侧     |         |
|---------|---------|
| wclk   | 写时钟     |
| wdata    | 数据输入端口  |
| w_en  | 置1写使能   |
| w_full  | 置1为写满   |
| wuse | fifo使用量 |

| 读取侧     |         |
|---------|---------|
| rclk   | 读时钟     |
| rdata    | 数据输出端口  |
| r_en   | 置1读使能   |
| r_empty | 置1为读空   |
| r_ok   | 可读信号   |
| ruse | fifo使用量 |




