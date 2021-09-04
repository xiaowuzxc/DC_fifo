echo "开始编译"
iverilog -g2005-sv -o tb -y ..\module ..\tb\tb_fifo_async.sv
echo "生成波形"
vvp -n tb -lxt2
echo "显示波形"
gtkwave tb.lxt