module HazzardDetection
(
	Ex_MemRead_i,
	Ex_RegisterRt_i,
	Id_RegisterRs_i,
	Id_RegisterRt_i,
	Jump_i,
	Branch_Equal_i,
	mux8_o,
	Hold_IfId_o,
	Hold_PC_o,
	rst_If_Id_o,
	Flush_o
);
input Ex_MemRead_i;
input [4:0] Ex_RegisterRt_i;
input [4:0] Id_RegisterRs_i;
input [4:0] Id_RegisterRt_i;
input Jump_i;
input Branch_Equal_i;
output mux8_o;
output Hold_IfId_o;
output Hold_PC_o;
output rst_If_Id_o;
output Flush_o;

assign rst_If_Id_o=(Jump_i || Branch_Equal_i)?0:1;
assign Flush_o=(Jump_i || Branch_Equal_i)?1:0;
assign mux8_o=(Ex_MemRead_i && (Ex_RegisterRt_i==Id_RegisterRs_i || Ex_RegisterRt_i==Id_RegisterRt_i))?1:0;
assign Hold_IfId_o=(Ex_MemRead_i && (Ex_RegisterRt_i==Id_RegisterRs_i || Ex_RegisterRt_i==Id_RegisterRt_i))?1:0;
assign Hold_PC_o=(Ex_MemRead_i && (Ex_RegisterRt_i==Id_RegisterRs_i || Ex_RegisterRt_i==Id_RegisterRt_i))?1:0;

endmodule