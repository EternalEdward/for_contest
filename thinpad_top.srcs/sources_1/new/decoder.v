`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2021 09:57:23 AM
// Design Name: 
// Module Name: decoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module decoder (
    input wire [31:0]inst,

    output reg sel_b_ext,

    output reg data_sram_wen,
    output reg data_sram_en,

    output reg [1:0]branch,
    output reg [1:0]alu_op,
    output reg [1:0]sel_ext,
    output reg reg_we,
    output reg mux_alu_mem,
    output reg sel_reg_we_addr,
    output reg stop_pc,
    output reg sel_lui//选择ALU/regfile2
    //output reg zero
); 
/*  
2'b00: 无符号
2'b01: 16  imm高位
2'b10:  有符号

alu_op:
00 +
01 -
10 |
11
*/
wire [5:0]opdecode;
wire [5:0]func;
assign opdecode = inst[31:26]; 
assign func = inst[5:0];

always @(*) begin
    case(opdecode)
    6'b000000:begin//addu
        case(func)
        6'b100001:begin
            mux_alu_mem <= 1'b1;//选alu的结果
            branch <= 2'b00;//不跳
            data_sram_en <= 1'b0;
            reg_we <= 1'b1;//写寄存器
            sel_b_ext <= 1'b0;//选b
            sel_reg_we_addr <= 1'b1;
            alu_op <= 2'b00;//+
            sel_lui <= 1'b1;
         //   zero <= 1'b0;
        end
        endcase
    end
    6'b001101:begin//ori
        mux_alu_mem <= 1'b1;//选alu的结果
        branch <= 2'b00;//不跳
        data_sram_en <= 1'b0;
        sel_ext <= 1'b0;//无符号
        //mem_wen <= 
        reg_we <= 1'b1;//写寄存器
        sel_b_ext <= 1'b1;//选imm
        sel_reg_we_addr <= 1'b0;
        alu_op <= 2'b01;//|
        sel_lui <= 1'b0;
        //zero <= 1'b0;
    end
    6'b001111:begin//lui
        mux_alu_mem <= 1'b1;//选alu的结果
        branch <= 2'b00;//不跳
        sel_ext <= 2'b01;//imm高位
        data_sram_en <= 1'b0;//mem_wen <= 
        reg_we <= 1'b1;//写寄存器
        sel_b_ext <= 1'b1;//选ext
        sel_reg_we_addr <= 1'b0;//ok
        alu_op <= 2'b00;//+ 
        sel_lui <= 1'b1;
      //  zero <= 1'b0;
    end
    6'b000101:begin//bne
       // mux_alu_mem <= 1'b1;//选alu的结果
        branch <= 2'b01;//跳
        sel_ext <= 2'b10;//0前无符号
        reg_we <= 1'b0;//no写寄存器
        sel_b_ext <= 1'b0;//选
        sel_reg_we_addr <= 1'b0;
        data_sram_en <= 1'b0;
        alu_op <= 2'b01;//-    
        //sel_lui <= 1'b0;
    end
    6'b100011:begin//lw写寄存器
        mux_alu_mem <= 1'b0;//选mem的结果读mem（不写）
        data_sram_en <= 1'b1;
        data_sram_wen <= 1'b0;
        branch <= 2'b00;//不跳
        sel_ext <= 2'b10;//有符号
        reg_we <= 1'b1;//写寄存器
        sel_b_ext <= 1'b1;//选ext   
        sel_reg_we_addr <= 1'b0;
        alu_op <= 2'b00;//+ 
        sel_lui <= 1'b0;
        //zero <= 1'b0;
    end
    6'b101011:begin//sw     要写mem
        mux_alu_mem <= 1'b1;//选alu的结果
        data_sram_en <= 1'b1;
        branch <= 2'b00;//不跳
        sel_ext <= 2'b10;//有符号
        data_sram_wen <= 1'b1;//dataRAM写使能
        reg_we <= 1'b0;//不写寄存器
        sel_b_ext <= 1'b1;//选ext
        sel_reg_we_addr <= 1'b0;//选了rt
        alu_op <= 2'b00;//+ 
        sel_lui <= 1'b0;
        //zero <= 1'b0;
    end
    endcase
end
endmodule