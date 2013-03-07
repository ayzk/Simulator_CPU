module Equal
(
	data1_i,
	data2_i,
	data_o
);
input [31:0] data1_i;
input [31:0] data2_i;
output data_o;

assign data_o=(data1_i==data2_i)?1:0;
endmodule