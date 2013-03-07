module PC
(
    clk_i,
    rst_i,
    start_i,
	hold_i,
    pc_i,
    pc_o
);

// Ports
input               clk_i;
input               rst_i;
input               start_i;
input               hold_i;
input   [31:0]      pc_i;
output  [31:0]      pc_o;

// Wires & Registers
reg     [31:0]      pc_o;


always@(posedge clk_i or negedge rst_i) begin
    if(~rst_i) begin
        pc_o <= 32'b0;
    end
    else begin
        if(start_i && !hold_i)
            pc_o <= pc_i;
        else
            pc_o <= pc_o;
    end
end

endmodule
