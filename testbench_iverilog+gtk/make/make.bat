echo "��ʼ����"
iverilog -g2005-sv -o tb -y ..\module ..\tb\tb_fifo_async.sv
echo "���ɲ���"
vvp -n tb -lxt2
echo "��ʾ����"
gtkwave tb.lxt