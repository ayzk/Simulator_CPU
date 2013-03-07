module Data_Memory
(
	clk_i,
	rst_i,
	addr_i,
	data_i,
	enable_i,
	write_i,
	ack_o,
	data_o
);

// Interface
input				    clk_i;
input				    rst_i;
input	[31:0]		addr_i;
input	[255:0]		data_i;
input				    enable_i;
input				    write_i;
output				  ack_o;
output	[255:0] data_o;


// Memory
reg		[255:0]		memory 			[0:511];	//16KB
reg		[3:0]		  count;
reg					    ack;
reg					    ok;
reg		[255:0]		data;
wire	[26:0]		addr;

parameter STATE_IDLE			= 3'h0,
					STATE_WAIT			= 3'h1,
					STATE_ACK			  = 3'h2,					
					STATE_FINISH		= 3'h3;

reg		[1:0]		state;

assign	ack_o = ack;
assign	addr = addr_i>>5;
assign	data_o = data;

//Controller 
always@(posedge clk_i or negedge rst_i) begin
	if(~rst_i) begin
		count <= 4'b0;
		ok <= 1'b0;
		ack <= 1'b0;
		state <= STATE_IDLE;
	end
    else begin
		case(state) 
			STATE_IDLE: begin
				if(enable_i) begin
					count <= count + 1;
					state <= STATE_WAIT;
				end
				else begin
					state <= STATE_IDLE;
				end
			end
			STATE_WAIT: begin
				if(count == 4'd6) begin	
					ok <= 1'b1;
					state <= STATE_ACK;
				end
				else begin
					count <= count + 1;
					state <= STATE_WAIT;
				end
			end
			STATE_ACK: begin
				count <= 4'b0;
				ok <= 1'b0;
				ack <= 1'b1;
				state <= STATE_FINISH;
			end
			STATE_FINISH: begin
				ack <= 1'b0;
				state <= STATE_IDLE;
			end
		endcase	
	end
end

// Read Data       
always@(posedge clk_i) begin
    if(ok && !write_i) begin
		data = memory[addr];
	end
end

// Write Data      
always@(posedge clk_i) begin
    if(ok && write_i) begin
		memory[addr] <= data_i;
	end
end



endmodule
