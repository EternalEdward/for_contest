module EXE (
    input rst,
    input [31:0]inst_i,
    input [31:0]caseA_i,
    input [31:0]caseB_i,
    input [7:0]alu_op_i,//运算类型
    input [2:0]alu_sel_i,//运算子类型
    input [4:0]reg_waddr_i,//不用管
    input reg_wen_i,

    input [31:0]link_addr_i,
    input delay_cao_en_i,

    //output zero,
    output reg [31:0]ALU_result,
    output reg [4:0]reg_waddr_o,
    output reg reg_wen_o,

    output [7:0]alu_op_o,
    output [31:0]mem_addr_o,
    output [31:0]caseB_o
    //output [31:0]maybe_addr_o;

);

reg [31:0]logic_result;
reg [31:0]ath_result;
reg [31:0]shift;

assign alu_op_o = alu_op_i;
assign mem_addr_o = caseA_i + {{16{inst_i[15]}},inst_i[15:0]};//base和offest
assign caseB_o = caseB_i;

always @(*) begin//逻辑
//alu_op_o <= 8'b00000100; //&
    if(rst)begin
        logic_result <= 32'h00000000;
    end else begin
        case (alu_op_i)
            8'b00000001:begin//OR_op
                logic_result <= caseA_i | caseB_i;
            end 
            8'b00000010:begin//AND_op
                logic_result <= caseA_i & caseB_i;
            end 
            8'b00000100:begin//XOR_op
                logic_result <= caseA_i ^ caseB_i;
            end 
            default: begin
                logic_result <= 32'h00000000;
            end
        endcase        
    end
end

always @(*) begin//移位
    if(rst)begin
        shift <= 32'h00000000;
    end
    else begin
        case (alu_op_i)
            8'b10000001: begin
                shift <= caseB_i << caseA_i[4:0];
            end
                
            8'b10000010: begin
                shift <= caseB_i >> caseA_i[4:0];
            end

            default:begin
            end 
        endcase
    end
end

always @(*) begin//算数
    if(rst)begin
        ath_result <= 32'h00000000;
    end
    else begin
        case (alu_op_i)
            8'b11000001: begin
                ath_result <= caseB_i + caseA_i;
            end
                
            8'b11000010: begin
                ath_result <= caseB_i * caseA_i;
            end

            default:begin
            end 
        endcase
    end
end

always @(*) begin
    if(rst)begin
        ALU_result <= 32'h00000000;
    end else begin
        reg_waddr_o <= reg_waddr_i;
        reg_wen_o <= reg_wen_i;
        case (alu_sel_i)
            3'b001: begin
                ALU_result <= logic_result;
            end
            3'b010: begin
                ALU_result <= shift;
            end
            3'b100: begin
                ALU_result <= ath_result;
            end
            3'b110: begin
                ALU_result <= link_addr_i;
            end
            default: begin
                ALU_result <= 32'h00000000;
            end
        endcase
    end
end

endmodule