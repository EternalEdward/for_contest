module MEM (
    input rst,

//  不用动
    input [31:0]ALU_result_i,
    input [4:0]reg_waddr_i,
    input reg_wen_i,

    input [7:0]alu_op_i,
    input [31:0]mem_addr_i,
    input [31:0]caseB_i,
    input [31:0]rom_data_i,

    output reg[31:0]mem_addr_o,
    output reg[31:0]rom_data_o,
    output reg mem_ce_o,
    output reg mem_we_o,

    output reg stallreq_o,

    output reg [31:0]ALU_result_o,
    output reg [4:0]reg_waddr_o,
    output reg reg_wen_o,
    output reg mem_read_en_o,

    output reg lw_flag_o, 
    output reg [31:0]new_data_lw_o
);
//wire [31:0] zero;
//reg mem_wen;
reg [31:0] old_addr_of_SW;
reg [31:0] old_data_of_SW;
//直接保存最近一次的存储数据
//assign mem_we_o = mem_wen;
//assign zero = 32'h00000000;

always @(*) begin
    if(rst)begin
        ALU_result_o <= 32'h00000000;
        reg_waddr_o <= 5'b00000; 
        reg_wen_o <= 1'b0;

        mem_addr_o <= 32'h00000000;
        rom_data_o <= 32'h00000000;
        old_addr_of_SW <= 32'h00000000;
        old_data_of_SW <= 32'h00000000;

        mem_ce_o <= 1'b0;
        mem_read_en_o <= 1'b0;
        mem_we_o <= 1'b0;
        stallreq_o <= 1'b0;
        lw_flag_o <=1'b0;

    end else begin
        ALU_result_o <= ALU_result_i;
        reg_waddr_o <= reg_waddr_i; 
        reg_wen_o <= reg_wen_i;

        //mem_addr_o <= 32'h00000000;
        //rom_data_o <= 32'h00000000;
        //mem_ce_o <= 1'b0;
        stallreq_o <= 1'b0;
        lw_flag_o <= 1'b0;

        case (alu_op_i)
            8'b11110001: begin//LW
                mem_addr_o <= mem_addr_i;
                //mem_sel_o <= 4'b0001;//LW
                ALU_result_o <= rom_data_i;
                mem_ce_o <= 1'b1;
                mem_we_o <= 1'b0;
                mem_read_en_o <= 1'b1;
                //stallreq_o <= 1'b1;
                //在这里读使能出问
                if(mem_addr_i == old_addr_of_SW)begin
                    new_data_lw_o <= old_data_of_SW;
                    lw_flag_o <= 1'b1;
                end
            end

            8'b11110010: begin//SW
                mem_addr_o <= mem_addr_i;
                old_addr_of_SW <=  mem_addr_i;
                old_data_of_SW <= caseB_i;
                //mem_sel_o <= 4'b0001;//SW同LW
                rom_data_o <= caseB_i;
                mem_ce_o <= 1'b1;
                mem_we_o <= 1'b1;
                mem_read_en_o <= 1'b0;
                //stallreq_o <= 1'b1;
            end
            default: begin
            end
        endcase
    end
end
    
endmodule