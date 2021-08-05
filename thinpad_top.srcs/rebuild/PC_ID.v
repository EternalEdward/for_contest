module PC_ID (
    input clk,
    input rst,

    input [31:0]pc_i,
    input [31:0]inst_i,
    input [5:0]stall,

    output reg [31:0]pc_to_ID,
    output reg [31:0]inst_to_ID

);

always @(posedge clk) begin
    if(rst)begin
        pc_to_ID <= 32'h00000000;
        inst_to_ID <= 32'h00000000;
    end else begin
        if(stall[1] == 1'b1 && stall[2] == 1'b0)begin
            pc_to_ID <= 32'h00000000;
            inst_to_ID <= 32'h00000000;
        end else begin
            if(stall[1] == 1'b0)begin
                pc_to_ID <= pc_i;
                inst_to_ID <= inst_i;
            end
        end
            
    end
end
    
endmodule