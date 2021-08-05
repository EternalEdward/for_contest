module ID_EXE (
    input rst,
    input clk,

    input [5:0]stall,

    input [7:0] id_to_exe_alu_op_i,
    input [2:0] id_to_exe_alu_sel_i,

    input id_to_exe_w_reg_en_i,
    input [4:0] id_to_exe_w_reg_addr_i,
    
    input [31:0] id_to_exe_caseA_i,
    input [31:0] id_to_exe_caseB_i,
//延迟槽
    input delay_cao_en_i,
    input [31:0] id_to_exe_link_addr_i,
    input id_to_exe_next_inst_delay_i,

//SW / LW
    input [31:0] from_id_inst_i,

    output reg[7:0] id_to_exe_alu_op_o,
    output reg[2:0] id_to_exe_alu_sel_o,

    output reg id_to_exe_w_reg_en_o,
    output reg [4:0]id_to_exe_w_reg_addr_o,

    output reg delay_cao_en_o,
    output reg [31:0] id_to_exe_link_addr_o,
    output reg id_to_exe_next_inst_delay_o,

    output reg [31:0]to_exe_inst_o,
    
    output reg[31:0] id_to_exe_caseA_o,
    output reg[31:0] id_to_exe_caseB_o
);

always @(posedge clk) begin
    if(rst)begin
        id_to_exe_alu_op_o <= 8'b00000000;
        id_to_exe_alu_sel_o <= 3'b000;

        id_to_exe_w_reg_en_o <= 1'b0;
        id_to_exe_w_reg_addr_o <= 5'b00000;
    
        id_to_exe_caseA_o <= 32'h00000000;
        id_to_exe_caseB_o <= 32'h00000000;
    end else begin
        if(stall[2] == 1'b1 && stall[3] == 1'b0)begin
            id_to_exe_alu_op_o <= 8'b00000000;
            id_to_exe_alu_sel_o <= 3'b000;

            id_to_exe_w_reg_en_o <= 1'b0;
            id_to_exe_w_reg_addr_o <= 5'b00000;

            id_to_exe_caseA_o <= 32'h00000000;
            id_to_exe_caseB_o <= 32'h00000000;
        end else begin
            if(stall[2] == 1'b0)begin
                id_to_exe_alu_op_o <= id_to_exe_alu_op_i;
                id_to_exe_alu_sel_o <= id_to_exe_alu_sel_i;

                id_to_exe_w_reg_en_o <= id_to_exe_w_reg_en_i;
                id_to_exe_w_reg_addr_o <= id_to_exe_w_reg_addr_i;
            
                id_to_exe_caseA_o <= id_to_exe_caseA_i;
                id_to_exe_caseB_o <= id_to_exe_caseB_i;

                delay_cao_en_o <= delay_cao_en_i;
                id_to_exe_link_addr_o <= id_to_exe_link_addr_i;
                id_to_exe_next_inst_delay_o <= id_to_exe_next_inst_delay_i;

                to_exe_inst_o <= from_id_inst_i; 
            end
        end
    end
end
endmodule