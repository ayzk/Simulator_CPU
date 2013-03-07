module dcache_data_sram
(
	clk_i,
	addr_i,
	data_i,
	enable_i,
	write_i,
	data_o
);

// Interface
input				  clk_i;
input	[4:0]		addr_i;
input	[255:0]	data_i;
input				  enable_i;
input				  write_i;

output	[255:0] 	data_o;


// Memory
reg		[255:0]		memory 			[0:31];	


// Write Data      
always@(posedge clk_i) begin
    if(enable_i && write_i) begin
		memory[addr_i]   <= data_i;
	end
end

// Read Data      
assign 	data_o = (enable_i) ? memory[addr_i] : 256'b0;


endmodule
