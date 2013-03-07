module Pipe_Register
(
    clk_i,
    rst_i,
    hold_i,
    reg_i,
    reg_o
);

// Ports
input               clk_i;
input               rst_i;
input               hold_i;
input   [255:0]      reg_i;
output  [255:0]      reg_o;

// Wires & Registers
reg     [255:0]      reg_o;


always@(posedge clk_i or negedge rst_i) begin
    if(~rst_i) begin
        reg_o <= 256'b0;
    end
    else begin
        if(hold_i)
            reg_o <= reg_o;
        else
            reg_o <= reg_i;
    end
end

endmodule

