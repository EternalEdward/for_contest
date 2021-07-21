`timescale 1ns / 1ps
module top(
    input wire clk_in,
    input wire rsten,

    output wire inst_sram_en,
    output wire [3:0] inst_sram_wen,
    output wire [31:0] inst_sram_addr,
    output wire [31:0] inst_sram_wdata,
    input wire [31:0] inst_sram_rdata,
  
    output wire data_sram_en,
    output wire data_sram_wen,
    output wire [31:0] data_sram_addr,
    output wire [31:0] data_sram_wdata,
    input wire [31:0] data_sram_rdata
);

//wire stall;

wire [31:0]premem_addr_un_mmu;
wire rst;
wire [31:0] pc_pc_o;
wire pc_ce_o;
wire [31:0]premem_addr_mmu;
wire sel_reg_we_addr;

assign rst = rsten;
//decoder
wire [31:0]mem_alu;

wire sel_B_ext;
//wire mux_b_mem;

wire [1:0]branch;
wire [1:0]alu_op;
wire [1:0]sel_ext;
wire reg_we_o;
wire  mux_alu_mem;

wire [4:0]raddr1;
wire [4:0]raddr2;

wire [4:0]reg_waddr;
wire [31:0]regwdata;

wire[31:0] rdata2;

wire  [1:0]aluop;
//reg   [1:0]b;//用来判断是不是branch
wire  [31:0]scaeA;
wire  [31:0]scaeB;
reg   [31:0]resultALU;
wire   zero;
wire sel_lui;
wire [31:0]ext_imm;
wire [15:0]new_imm_pc;
wire [31:0]targe_adder;
//pc
pc topc(
    .clk(clk_in),
    .rst(rsten),

    .zero_in(zero),
    .targe_adder(targe_adder),

    .ce(pc_ce_o),

    .pc(pc_pc_o)
    //.stall(stall)
);
//decoder
assign inst_sram_en = rst ? 1'b0 : pc_ce_o;
assign inst_sram_wen = 4'b0000;
assign inst_sram_addr = rst ? 32'h00000000 :  (pc_pc_o - 32'h80000000);
assign inst_sram_wdata = 32'h00000000;

/*ctrl ctrler(
    .rst(rst),
    .clk(clk_in),
    .from_ex(from_ex),
    .stall(stall)
);*/

leftmove_2 lmove(
    .old_imm(inst_sram_rdata[15:0]),
    .new_imm(new_imm_pc)
);

//decoder
decoder de_coder(
    .inst(inst_sram_rdata),
    .sel_b_ext(sel_B_ext),
    .data_sram_wen(data_sram_wen),
    .data_sram_en(data_sram_en),
    .branch(branch),
    .alu_op(alu_op),
    .mux_alu_mem(mux_alu_mem),
    .sel_ext(sel_ext),
    .reg_we(reg_we_o),
    .sel_reg_we_addr(sel_reg_we_addr),
    .sel_lui(sel_lui)
    //单独给lui指令做一个多路选择器
);
//

mux_2 mux_mem_alu(//大概准备给选B和mem 
    .sel(mux_alu_mem),
    .in_1(data_sram_rdata),//0
    .in_2(scaeB),//1
    .out(mem_alu)
);

mux_2 mux_lui(
    .sel(sel_lui),
    .in_1(mem_alu),//0
    .in_2(premem_addr_un_mmu),//1//ALU计算得到的结果
    .out(regwdata)
    
);

/////////////////////////////////////////////
mux_2_5 mux_reg(//write寄存器addr的多路选择器
    .x(inst_sram_rdata[15:11]),//1
    .y(inst_sram_rdata[20:16]),//0
    .sel(sel_reg_we_addr),
    .z(reg_waddr)
);


//mux_ext_
regfile regss(
    .clk(clk_in),
    .rst(rsten),

    .raddr1(inst_sram_rdata[25:21]),
    .raddr2(inst_sram_rdata[20:16]),

    .we(reg_we_o),//写使能
    .waddr(reg_waddr),
    .wdata(regwdata),

    .rdata1(scaeA),
    .rdata2(rdata2)
);

//ext
ext extend_u(
    .sel(sel_ext),
    .old_imm(inst_sram_rdata[15:0]),
    .new_imm(ext_imm)
);
//mux
ext extend_u_pc(
    .sel(sel_ext),
    .old_imm(new_imm_pc),
    .new_imm(targe_adder)
);
mux_2 mux_B_imm(
    .sel(sel_B_ext),
    .in_1(rdata2),//0
    .in_2(ext_imm),//1
    .out(scaeB)
);


//ALU
ALU alu_top(
    .aluop(alu_op),
    .b(branch),
    .scaeA(scaeA),
    .scaeB(scaeB),
    .resultALU(premem_addr_un_mmu),
    .zero(zero)
);

//mmu
assign premem_addr_mmu = (premem_addr_un_mmu < 32'h80000000) ? premem_addr_un_mmu :
                            (premem_addr_un_mmu < 32'hA0000000) ? (premem_addr_un_mmu - 32'h80000000) :
                            (premem_addr_un_mmu < 32'hC0000000) ? (premem_addr_un_mmu - 32'hA0000000) :
                            (premem_addr_un_mmu < 32'hE0000000) ? (premem_addr_un_mmu) :
                            (premem_addr_un_mmu <= 32'hFFFFFFFF) ? (premem_addr_un_mmu) : 
                            32'h00000000;


//mem
assign data_sram_addr = rst ? 32'h00000000 : premem_addr_mmu;
assign data_sram_wdata = rst ? 32'h00000000 : rdata2;


endmodule