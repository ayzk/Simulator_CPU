module ALU(
	data1_i,
	data2_i,
	ALUCtrl_i,
	data_o,
	Zero_o
);

input signed [31:0] data1_i;
input signed [31:0] data2_i;
input [2:0] ALUCtrl_i;
output signed [31:0] data_o;
reg signed[31:0] data_o_1;
output Zero_o;
assign Zero_o=data1_i==data2_i? 1: 0;
assign data_o=data_o_1;

parameter   AND=3'b000,
			OR =3'b001,
			ADD=3'b010,
			SUB=3'b110,
			MUL=3'b111;
			
always @(data1_i or data2_i or ALUCtrl_i)
begin
	case (ALUCtrl_i)
		ADD:data_o_1=data1_i+data2_i;
		SUB:data_o_1=data1_i-data2_i;
		AND:data_o_1=data1_i&data2_i;
		OR:data_o_1=data1_i|data2_i;
		MUL:data_o_1=data1_i*data2_i;
		default:data_o_1=data1_i;
	endcase
end
endmodule 
