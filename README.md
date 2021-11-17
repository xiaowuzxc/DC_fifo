## 介绍
使用verilog编写的异步fifo，读写端口各有一组时钟、读写使能、读写端口、满空指示、fifo使用量。在源码中对每个模块都进行注释，易于学习参考。  
fifo_async.v为源文件，fifo_async.pdf为RTL视图。  
testbench文件夹中有建立好的仿真工程，分别是VCS+Verdi和iverilog+gtkwave。喜欢哪个用哪个，配好环境make就行了。  
iverilog+gtkwave加入windows支持。  
如果觉得不错，可以去B站支持一下[详解异步FIFO原理与Verilog模型](https://www.bilibili.com/read/cv13048274)。  
日后还会持续更新完善  
## 模块接口
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




