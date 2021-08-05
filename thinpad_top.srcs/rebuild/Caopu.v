module Caopu (
    input clk_i,
    input rst_i,
    
    input [31:0]inst_rom_data_i,
    
    output inst_rom_en_o,
    output [31:0]inst_rom_addr_o,

    output data_rom_en,
    output data_rom_wen,
    output [31:0]data_rom_addr,
    output [31:0]data_rom_wdata,
    output [31:0]data_rom_rdata,
    output wire data_rom_read_en
);
//
wire [31:0]pc_o;
wire [5:0]stall;

wire [31:0]pc_to_ID;
wire [31:0]inst_to_ID;

wire [31:0]branch_target_addr;

///from wb
wire [31:0]mem_to_wb_data_o;
wire [4:0]mem_to_wb_reg_waddr_o;
wire mem_to_wb_reg_wen_o;

wire [7:0]id_alu_op_o;
wire [2:0]id_alu_sel_o;
  
wire [4:0]id_read_reg_addr1_o;
wire [4:0]id_read_reg_addr2_o;
wire id_read_reg1_en;
wire id_read_reg2_en;

wire [4:0]id_w_reg_addr_o;

wire id_w_reg_en_o;

wire [31:0]id_read_reg_data1_i;
wire [31:0]id_read_reg_data2_i;
wire [31:0]id_w_reg_data_i;

wire [31:0]id_caseA_o;
wire [31:0]id_caseB_o;

wire [7:0] id_to_exe_alu_op_o;
wire [2:0] id_to_exe_alu_sel_o;

wire id_to_exe_w_reg_en_o;
wire [4:0] id_to_exe_w_reg_addr_o;

wire [31:0] id_to_exe_caseA_o;
wire [31:0] id_to_exe_caseB_o;

wire exe_zero;
wire [31:0]exe_ALU_result_o;
wire [4:0]exe_reg_waddr_o;
wire exe_reg_wen_o;

wire [31:0]exe_to_mem_ALU_result;
wire [4:0]exe_to_mem_reg_waddr_o;
wire exe_to_mem_reg_wen_o;

wire [31:0]ALU_result_o;
wire [4:0]reg_waddr_o;
wire mem_reg_wen_o;

wire ID_next_inst_delay_o;
wire branch_en_o;
wire [31:0]branch_target_addr_o;
wire [31:0]ID_link_addr_o;
wire ID_delay_cao_en_o;
wire ID_stallreq_o;
wire [31:0]ID_inst_o;

wire ID_EXE_delay_cao_en_o;
wire [31:0]id_to_exe_link_addr_o;
wire id_to_exe_next_inst_delay_o;
wire [31:0]to_exe_inst_o;

wire [7:0]EXE_alu_op_o;
wire [31:0]EXE_mem_addr_o;
wire [31:0]EXE_caseB_o;

wire [7:0] EXE_MEM_exe_alu_op_o;
wire [31:0] EXE_MEM_exe_to_mem_addr_o;
wire [31:0] EXE_MEM_exe_caseB_o;


wire  mem_stallreq_o;

wire MEM_lw_flag_o;
wire [31:0]MEM_new_data_lw_o;

CTRL CTRL_cpu(
    //.clk(clk_i),
    .rst(rst_i),
    .pasue_from_id(ID_stallreq_o),
    //.pasue_from_id(1'b0),
    .pasue_from_exe(1'b0),
    .pasue_from_mem(mem_stallreq_o),
    .stall(stall)
);

pc pc_cpu(
    .clk(clk_i),
    .stall(stall),
    .rst(rst_i),
    .pc(pc_o),
    .branch_en_i(branch_en_o),
    .branch_target_addr_i(branch_target_addr_o),
    .ce(inst_rom_en_o)
);

assign inst_rom_addr_o = pc_o;

PC_ID PC_ID_cpu(
    .clk(clk_i),
    .rst(rst_i),

    .pc_i(pc_o),
    .inst_i(inst_rom_data_i),
    .stall(stall),

    .pc_to_ID(pc_to_ID),
    .inst_to_ID(inst_to_ID)
);



ID ID_cpu (
    .rst(rst_i),

    .inst_i(inst_to_ID),
    .pc_i(pc_to_ID), 
    .stallreq_o(ID_stallreq_o),

    .inst_o(ID_inst_o),
    //前推
//  from exe
    .exe_w_reg_en_i(exe_reg_wen_o),
    .exe_reg_wdata_i(exe_ALU_result_o),
    .exe_reg_waddr_i(exe_reg_waddr_o),

// from mem 
    .mem_w_reg_en_i(mem_reg_wen_o),
    .mem_reg_wdata_i(ALU_result_o),
    .mem_reg_waddr_i(reg_waddr_o),

    .alu_op_o(id_alu_op_o),
    .alu_sel_o(id_alu_sel_o),
  
    .read_reg_addr1_o(id_read_reg_addr1_o),
    .read_reg_addr2_o(id_read_reg_addr2_o),
    .read_reg1_en(id_read_reg1_en),
    .read_reg2_en(id_read_reg2_en),

    .w_reg_addr_o(id_w_reg_addr_o),
    .w_reg_en(id_w_reg_en_o),


    .read_reg_data1_i(id_read_reg_data1_i),
    .read_reg_data2_i(id_read_reg_data2_i),

    //延迟槽
    .delay_cao_en_i(ID_EXE_delay_cao_en_o),
    //从ID_EXE写到ID

    .next_inst_delay_o(ID_next_inst_delay_o),
    .branch_en_o(branch_en_o),
    .branch_target_addr_o(branch_target_addr_o),
    .link_addr_o(ID_link_addr_o),
    .delay_cao_en_o(ID_delay_cao_en_o),


//       LW 
    .new_data_lw_o(MEM_new_data_lw_o),
    .lw_flag_i(MEM_lw_flag_o),

    .caseA_o(id_caseA_o),
    .caseB_o(id_caseB_o)
);

regfile regs(
    .clk(clk_i),
    .rst(rst_i),

    .ren1(id_read_reg1_en),
    .raddr1(id_read_reg_addr1_o),
    .ren2(id_read_reg2_en),
//
    .raddr2(id_read_reg_addr2_o),
//from wb
    .we(mem_to_wb_reg_wen_o),//写使能
    .waddr(mem_to_wb_reg_waddr_o),
    .wdata(mem_to_wb_data_o),

    .rdata1(id_read_reg_data1_i),
    .rdata2(id_read_reg_data2_i)

);



ID_EXE ID_EXE_cpu(
    .rst(rst_i),
    .clk(clk_i),

    .stall(stall),

    .id_to_exe_alu_op_i(id_alu_op_o),
    .id_to_exe_alu_sel_i(id_alu_sel_o),

    .id_to_exe_w_reg_en_i(id_w_reg_en_o),
    .id_to_exe_w_reg_addr_i(id_w_reg_addr_o),

    .id_to_exe_caseA_i(id_caseA_o),
    .id_to_exe_caseB_i(id_caseB_o),
//延迟槽
    .delay_cao_en_i(ID_delay_cao_en_o),
    .id_to_exe_link_addr_i(ID_link_addr_o),
    .id_to_exe_next_inst_delay_i(ID_next_inst_delay_o),
    
//SW / LW
    .from_id_inst_i(ID_inst_o),

    .id_to_exe_alu_op_o(id_to_exe_alu_op_o),
    .id_to_exe_alu_sel_o(id_to_exe_alu_sel_o),

    .id_to_exe_w_reg_en_o(id_to_exe_w_reg_en_o),
    .id_to_exe_w_reg_addr_o(id_to_exe_w_reg_addr_o),

    .delay_cao_en_o(ID_EXE_delay_cao_en_o),
    .id_to_exe_link_addr_o(id_to_exe_link_addr_o),
    .id_to_exe_next_inst_delay_o(id_to_exe_next_inst_delay_o),

    .to_exe_inst_o(to_exe_inst_o),

    .id_to_exe_caseA_o(id_to_exe_caseA_o),
    .id_to_exe_caseB_o(id_to_exe_caseB_o)
);
///////改到这里了

EXE EXE_cpu(
    .rst(rst_i),
    .inst_i(to_exe_inst_o),
    .caseA_i(id_to_exe_caseA_o),
    .caseB_i(id_to_exe_caseB_o),
    .alu_op_i(id_to_exe_alu_op_o),//运算类型
    .alu_sel_i(id_to_exe_alu_sel_o),//运算子类型
    .reg_waddr_i(id_to_exe_w_reg_addr_o),//不用管
    .reg_wen_i(id_to_exe_w_reg_en_o),

    .link_addr_i(id_to_exe_link_addr_o),
    .delay_cao_en_i(ID_EXE_delay_cao_en_o),

    //.zero(exe_zero),
    .ALU_result(exe_ALU_result_o),
    .reg_waddr_o(exe_reg_waddr_o),
    .reg_wen_o(exe_reg_wen_o),

    .alu_op_o(EXE_alu_op_o),
    .mem_addr_o(EXE_mem_addr_o),
    .caseB_o(EXE_caseB_o)
);



EXE_MEM EXE_MEM_cpu(
    .clk(clk_i),
    .rst(rst_i),

    .stall(stall),
    .exe_to_mem_ALU_result_i(exe_ALU_result_o),
    .exe_to_mem_reg_waddr_i(exe_reg_waddr_o),
    .exe_to_mem_reg_wen_i(exe_reg_wen_o),

    .exe_alu_op_i(EXE_alu_op_o),
    .exe_to_mem_addr_i(EXE_mem_addr_o),
    .exe_caseB_i(EXE_caseB_o),

    .exe_alu_op_o(EXE_MEM_exe_alu_op_o),
    .exe_to_mem_addr_o(EXE_MEM_exe_to_mem_addr_o),
    .exe_caseB_o(EXE_MEM_exe_caseB_o),

    .exe_to_mem_ALU_result(exe_to_mem_ALU_result),
    .exe_to_mem_reg_waddr_o(exe_to_mem_reg_waddr_o),
    .exe_to_mem_reg_wen_o(exe_to_mem_reg_wen_o)
);



MEM MEM_cpu(
    .rst(rst_i),

    .ALU_result_i(exe_ALU_result_o),
    .reg_waddr_i(exe_reg_waddr_o),
    .reg_wen_i(exe_reg_wen_o),

    .alu_op_i(EXE_MEM_exe_alu_op_o),
    .mem_addr_i(EXE_MEM_exe_to_mem_addr_o),
    .caseB_i(EXE_MEM_exe_caseB_o),
    .rom_data_i(data_rom_rdata),//从ROM拿

    .mem_addr_o(data_rom_addr),
    .rom_data_o(data_rom_wdata),
    .mem_ce_o(data_rom_en),
    .mem_we_o(data_rom_wen),

    .ALU_result_o(ALU_result_o),
    .reg_waddr_o(reg_waddr_o),
    .reg_wen_o(mem_reg_wen_o),
    .mem_read_en_o(data_rom_read_en),

    .stallreq_o(mem_stallreq_o),

    .lw_flag_o(MEM_lw_flag_o), 
    .new_data_lw_o(MEM_new_data_lw_o)
);

MEM_WB MEM_WB_cpu(
    .rst(rst_i),
    .clk(clk_i),

    .stall(stall),

    .mem_to_wb_ALU_result_i(ALU_result_o),
    .mem_to_wb_reg_waddr_i(reg_waddr_o),
    .mem_to_wb_reg_wen_i(mem_reg_wen_o),

    .mem_to_wb_data_o(mem_to_wb_data_o),
    .mem_to_wb_reg_waddr_o(mem_to_wb_reg_waddr_o),
    .mem_to_wb_reg_wen_o(mem_to_wb_reg_wen_o)
);

endmodule