module Control(
    Op_i,       
    RegDst_o,  
    ALUOp_o, 
    ALUSrc_o,  
    Branch_o,
    MemRead_o,
    MemWrite_o,
    RegWrite_o,
    MemtoReg_o,
    Jump_o,
);

input [5:0] Op_i;
output RegDst_o;
output reg [1:0] ALUOp_o;
output ALUSrc_o;
output Branch_o;
output MemRead_o;
output MemWrite_o;
output MemtoReg_o;
output RegWrite_o;
output Jump_o;

assign RegDst_o=(Op_i==6'b000000) ? 1:0;
assign ALUSrc_o=(Op_i==6'b001000 || Op_i==6'b100011 || Op_i ==6'b101011)? 1:0;
assign MemtoReg_o=(Op_i==6'b100011)?1:0;
assign RegWrite_o=(Op_i==6'b000000 || Op_i==6'b001000 || Op_i==6'b100011)?1:0;
assign MemWrite_o=(Op_i==6'b101011)?1:0;
assign MemRead_o=(Op_i==6'b100011)?1:0;
assign Branch_o=(Op_i==6'b000100)?1:0;
assign Jump_o=(Op_i==6'b000010)?1:0;

always@*
begin
  case (Op_i)
    6'b000000:ALUOp_o=2'b11;
    6'b001000:ALUOp_o=2'b00;
    6'b100011:ALUOp_o=2'b00;
    6'b101011:ALUOp_o=2'b00;
    6'b000100:ALUOp_o=2'b01;
  endcase
end

endmodule



