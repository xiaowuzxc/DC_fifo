# 异步FIFO的纯verilog实现

#### 介绍
使用verilog编写的异步fifo，读写端口各有一组时钟、读写使能、读写端口、满空指示、fifo使用量。本模块既不可靠，也不成熟，更不实用；注释写得多，可以作为学习参考。

#### 模块架构
架构说明

aclr：异步复位，同步释放端口

| 写入侧     |         |
|---------|---------|
| wrclk   | 写时钟     |
| data    | 数据输入端口  |
| wrreq   | 置1写使能   |
| wrfull  | 置1为写满   |
| wrusedw | fifo使用量 |

| 读取侧     |         |
|---------|---------|
| rdclk   | 读时钟     |
| q       | 数据输出端口  |
| rdreq   | 置1读使能   |
| rdempty | 置1为读空   |
| rdusedw | fifo使用量 |


![输入图片说明](https://images.gitee.com/uploads/images/2021/0730/195358_7e1fa6b9_8241888.png "未命名绘图.png")

