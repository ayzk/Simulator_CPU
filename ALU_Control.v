module ALU_Control(
   funct_i,    
   ALUOp_i,    
   ALUCtrl_o 
);

input [5:0] funct_i;
input [1:0] ALUOp_i;
output [2:0] ALUCtrl_o;
reg[2:0] ALUCtrl_o_1;
assign ALUCtrl_o=ALUCtrl_o_1;

parameter   AND=3'b000,
			OR =3'b001,
			ADD=3'b010,
			SUB=3'b110,
			MUL=3'b111;
			
always @(funct_i or ALUOp_i)
begin
	case (ALUOp_i)
		  2'b00: ALUCtrl_o_1<=ADD;
		  2'b01: ALUCtrl_o_1<=SUB;
		  2'b10: ALUCtrl_o_1<=OR;
	    2'b11: case (funct_i)
				 6'b100000:ALUCtrl_o_1<=ADD;
				 6'b100010:ALUCtrl_o_1<=SUB;
				 6'b100100:ALUCtrl_o_1<=AND;
				 6'b100101:ALUCtrl_o_1<=OR;
				 6'b011000:ALUCtrl_o_1<=MUL;
				  default:ALUCtrl_o_1<=AND;
			    endcase 				 
		default:ALUCtrl_o_1<=AND;
	endcase 
end
endmodule 