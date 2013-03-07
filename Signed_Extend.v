module Signed_Extend(
	data_i,
	data_o
);

input [15:0] data_i;
output wire [31:0] data_o;
assign data_o = {{16{data_i[15]}},data_i};
endmodule 