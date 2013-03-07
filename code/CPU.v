module CPU
(
    clk_i, 
    rst_i,
    start_i,
	
	mem_data_i, 
	mem_ack_i, 	
	mem_data_o, 
	mem_addr_o, 	
	mem_enable_o, 
	mem_write_o
);

// Ports
input               clk_i;
input               rst_i;
input               start_i;

//
// to Data Memory interface		
//
input	[256-1:0]	mem_data_i; 
input				mem_ack_i; 	
output	[256-1:0]	mem_data_o; 
output	[32-1:0]	mem_addr_o; 	
output				mem_enable_o; 
output				mem_write_o; 


//wire
wire [31:0] inst;

wire [255:0] if_id_reg_i;
wire [255:0] if_id_reg_o;
wire [255:0] id_ex_reg_i;
wire [255:0] id_ex_reg_o;
wire [255:0] ex_mem_reg_i;
wire [255:0] ex_mem_reg_o;
wire [255:0] mem_wb_reg_i;
wire [255:0] mem_wb_reg_o;

wire alusrc,regdst,memread,memwrite,regwrite,memtoreg;
wire [1:0] aluop;
wire cache_stall;


wire stall_PC; 
or (stall_PC,cache_stall,hazzard_detection_hold_pc_o);
PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
	.hold_i		(stall_PC),
    .pc_i       (Mux2.data_o),
    .pc_o       (Instruction_Memory.addr_i)
);

Instruction_Memory Instruction_Memory(
    .addr_i     (PC.pc_o), 
    .instr_o    (if_id_reg_i[31:0])
);

Adder Add_PC(
    .data1_in   (PC.pc_o),
    .data2_in   (32'd4),
    .data_o     (if_id_reg_i[63:32])
);



MUX32 Mux1
//branch
(
	.data1_i(Add_PC.data_o),
	.data2_i(Add.data_o),
	.select_i(branch_equal),
	.data_o(Mux2.data1_i)
);

wire [31:0] mux2_data2_i;
assign mux2_data2_i[1:0]=2'b00;
assign mux2_data2_i[27:2]=inst[25:0];
assign mux2_data2_i[31:28]=Add_PC.data_o[31:28];
MUX32 Mux2
//jump
(
	.data1_i(Mux1.data_o),
	.data2_i(mux2_data2_i),
	.select_i(Control.Jump_o),
	.data_o(PC.pc_i)
);


wire rst_If_Id;
and (rst_If_Id,rst_i,HazzardDetection.rst_If_Id_o);

wire stall_If_Id; 
or (stall_If_Id,cache_stall,hazzard_detection_hold_ifid_o);

Pipe_Register If_Id
(
	.clk_i(clk_i),
	.rst_i(rst_If_Id),
	.hold_i(stall_If_Id),
	.reg_i(if_id_reg_i),
	.reg_o(if_id_reg_o)
);
assign inst[31:0]=if_id_reg_o[31:0];

wire equal,branch;
Equal Equal
(
	.data1_i(Registers.RSdata_o),
	.data2_i(Registers.RTdata_o),
	.data_o(equal)
);
and (branch_equal,equal,branch);

HazzardDetection HazzardDetection
(
	.Ex_MemRead_i(id_ex_reg_o[132:132]),
	.Ex_RegisterRt_i(id_ex_reg_o[9:5]),
	.Id_RegisterRs_i(inst[25:21]),
	.Id_RegisterRt_i(inst[20:16]),
	.Jump_i(Control.Jump_o),
	.Branch_Equal_i(branch_equal),
	.mux8_o(Mux8.select_i),
	.Hold_IfId_o(hazzard_detection_hold_ifid_o),
	.Hold_PC_o(hazzard_detection_hold_pc_o),
	.rst_If_Id_o()
);

Adder Add
(
	.data1_in({Signed_Extend.data_o[29:0],2'b00}),
	.data2_in(if_id_reg_o[63:32]),
	.data_o(Mux1.data2_i)
);
wire [31:0] mux8_data1_i;

Control Control(
    .Op_i(inst[31:26]),       
    .RegDst_o(mux8_data1_i[0:0]),  
    .ALUOp_o(mux8_data1_i[2:1]), 
    .ALUSrc_o(mux8_data1_i[3:3]),  
    .Branch_o(branch),
    .MemRead_o(mux8_data1_i[4:4]),
    .MemWrite_o(mux8_data1_i[5:5]),
    .RegWrite_o(mux8_data1_i[6:6]),
    .MemtoReg_o(mux8_data1_i[7:7]),
    .Jump_o(Mux2.select_i)
);

assign regdst=id_ex_reg_o[128:128];
assign aluop[1:0]=id_ex_reg_o[130:129];
assign alusrc=id_ex_reg_o[131:131];
assign memread=ex_mem_reg_o[132:132];
assign memwrite=ex_mem_reg_o[133:133];
assign regwrite=mem_wb_reg_o[134:134];
assign memtoreg=mem_wb_reg_o[135:135];

MUX32 Mux8
(	
	.data1_i(mux8_data1_i),
	.data2_i(32'b0),
	.select_i(HazzardDetection.mux8_o),
	.data_o(id_ex_reg_i[159:128])
);

Registers Registers(
    .clk_i      (clk_i),
    .RSaddr_i   (inst[25:21]),
    .RTaddr_i   (inst[20:16]),
    .RDaddr_i   (mem_wb_reg_o[4:0]), 
    .RDdata_i   (Mux5.data_o),
    .RegWrite_i (regwrite), 
    .RSdata_o   (id_ex_reg_i[127:96]), 
    .RTdata_o   (id_ex_reg_i[95:64]) 
);



Signed_Extend Signed_Extend(
    .data_i     (inst[15:0]),
    .data_o     (id_ex_reg_i[63:32])
);


assign id_ex_reg_i[19:0]={inst[25:21],inst[20:16],inst[20:16],inst[15:11]};
Pipe_Register Id_Ex
(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.hold_i(cache_stall),
	.reg_i(id_ex_reg_i),
	.reg_o(id_ex_reg_o)
);



MUX5 Mux3
(
	.data1_i(id_ex_reg_o[9:5]),
	.data2_i(id_ex_reg_o[4:0]),
	.select_i(regdst),
	.data_o(ex_mem_reg_i[4:0])
);

MUX32_3 Mux6
(
	.data1_i(id_ex_reg_o[127:96]),
	.data2_i(Mux5.data_o),
	.data3_i(ex_mem_reg_o[95:64]),
	.select_i(Forward.ForwardA_o),
	.data_o(ALU.data1_i)
);

MUX32_3 Mux7
(
	.data1_i(id_ex_reg_o[95:64]),
	.data2_i(Mux5.data_o),
	.data3_i(ex_mem_reg_o[95:64]),
	.select_i(Forward.ForwardB_o),
	.data_o(Mux4.data1_i)
);

MUX32 Mux4
(
	.data1_i(Mux7.data_o),
	.data2_i(id_ex_reg_o[63:32]),
	.select_i(alusrc),
	.data_o(ALU.data2_i)
);

ALU ALU(
    .data1_i    (Mux6.data_o),
    .data2_i    (Mux4.data_o),
    .ALUCtrl_i  (ALU_Control.ALUCtrl_o),
    .data_o     (ex_mem_reg_i[95:64]),
    .Zero_o     ()
);



ALU_Control ALU_Control(
    .funct_i    (id_ex_reg_o[37:32]),
    .ALUOp_i    (aluop),
    .ALUCtrl_o  (ALU.ALUCtrl_i)
);

Forward Forward
(
    .Ex_RegisterRs_i(id_ex_reg_o[19:15]),
    .Ex_RegisterRt_i(id_ex_reg_o[14:10]),
    .Mem_RegWrite_i(ex_mem_reg_o[134:134]),
    .Mem_Register_i(ex_mem_reg_o[4:0]),
    .Wb_RegWrite_i(mem_wb_reg_o[134:134]),
    .Wb_Register_i(mem_wb_reg_o[4:0]),
    .ForwardA_o(Mux6.select_i),
    .ForwardB_o(Mux7.select_i) 
);

assign ex_mem_reg_i[63:32]=Mux7.data_o;
assign ex_mem_reg_i[159:128]=id_ex_reg_o[159:128];
Pipe_Register Ex_Mem
(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.hold_i(cache_stall),
	.reg_i(ex_mem_reg_i),
	.reg_o(ex_mem_reg_o)
);

//Data_Memory Data_Memory
//(
//	.clk_i(clk_i),
//	.Address_i(ex_mem_reg_o[95:64]),
//	.WriteData_i(ex_mem_reg_o[63:32]),
//	.MemWrite_i(memwrite),
//	.MemRead_i(memread),
//	.ReadData_o(mem_wb_reg_i[95:64])
//);

//data cache
dcache_top dcache
(
    // System clock, reset and stall
	.clk_i(clk_i), 
	.rst_i(rst_i),
	
	// to Data Memory interface		
	.mem_data_i(mem_data_i), 
	.mem_ack_i(mem_ack_i), 	
	.mem_data_o(mem_data_o), 
	.mem_addr_o(mem_addr_o), 	
	.mem_enable_o(mem_enable_o), 
	.mem_write_o(mem_write_o), 
	
	// to CPU interface	
	.p1_data_i(ex_mem_reg_o[63:32]), 
	.p1_addr_i(ex_mem_reg_o[95:64]), 	
	.p1_MemRead_i(memread), 
	.p1_MemWrite_i(memwrite), 
	.p1_data_o(mem_wb_reg_i[95:64]), 
	.p1_stall_o(cache_stall)
);



assign mem_wb_reg_i[31:0]=ex_mem_reg_o[31:0];
assign mem_wb_reg_i[63:32]=ex_mem_reg_o[95:64];
assign mem_wb_reg_i[159:128]=ex_mem_reg_o[159:128];
Pipe_Register Mem_Wb
(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.hold_i(cache_stall),
	.reg_i(mem_wb_reg_i),
	.reg_o(mem_wb_reg_o)
);

MUX32 Mux5
(
	.data1_i(mem_wb_reg_o[63:32]),
	.data2_i(mem_wb_reg_o[95:64]),
	.select_i(memtoreg),
	.data_o(Registers.RDdata_i)
);

endmodule

