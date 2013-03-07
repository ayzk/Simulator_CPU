module Forward
(
    Ex_RegisterRs_i,
    Ex_RegisterRt_i,
    Mem_RegWrite_i,
    Mem_Register_i,
    Wb_RegWrite_i,
    Wb_Register_i,
    ForwardA_o,
    ForwardB_o,  
);
input [4:0]   Ex_RegisterRs_i;
input [4:0]    Ex_RegisterRt_i;

input    Mem_RegWrite_i;
input [4:0]   Mem_Register_i;

input    Wb_RegWrite_i;
input [4:0]   Wb_Register_i;
output [1:0]    ForwardA_o;
output [1:0]    ForwardB_o;  
assign ForwardA_o=( (Mem_RegWrite_i) && (Mem_Register_i!=0) &&(Mem_Register_i==Ex_RegisterRs_i) ) ? 2'b10
                   : ( ( (Wb_RegWrite_i) && (Wb_Register_i!=0) && (Mem_Register_i!=Ex_RegisterRs_i)
						&& (Wb_Register_i==Ex_RegisterRs_i) ) ? 2'b01
					:2'b00);
assign ForwardB_o=( (Mem_RegWrite_i) && (Mem_Register_i!=0) &&(Mem_Register_i==Ex_RegisterRt_i) ) ? 2'b10
                   : ( ( (Wb_RegWrite_i) && (Wb_Register_i!=0) && (Mem_Register_i!=Ex_RegisterRt_i)
						&& (Wb_Register_i==Ex_RegisterRt_i) ) ? 2'b01
					:2'b00);					

endmodule