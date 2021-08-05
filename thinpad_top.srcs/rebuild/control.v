module control(
    input [5:0]control_in,

    output reg reg_dst,
    output reg branch,
    output reg mem_read,//先写这不知道有没有用
    output reg mem_to_flag,
    output reg [2:0]alu_op,
    output reg mem_wen,
    output reg alu_sel,
    output reg reg_wen,
    output reg [1:0]sel_ext_type
);
always @(*) begin
    case (control_in)
        6'b001101://ori
        begin
            reg_dst <= 1'b0;
            branch <= 1'b0;
            mem_read <= 1'b0;//先写这不知道有没有用
            mem_to_flag <= 1'b0;
            alu_op <= 3'b001;// |
            mem_wen <= 1'b0;
            alu_sel <= 1'b1;//sel imm
            reg_wen <= 1'b1;
            sel_ext_type <= 2'b00;//unsign
        end

        6'b001111://lui
        begin
            reg_dst <= 1'b0;
            branch <= 1'b0;
            mem_read <= 1'b0;//先写这不知道有没有用
            mem_to_flag <= 1'b0;
            alu_op <= 3'b001;// |
            mem_wen <= 1'b0;
            alu_sel <= 1'b1;//sel imm
            reg_wen <= 1'b1;
            sel_ext_type <= 2'b01;//hight16
        end

        6'b000000://先当addu
        begin
            reg_dst <= 1'b1;
            branch <= 1'b0;
            mem_read <= 1'b0;//先写这不知道有没有用
            mem_to_flag <= 1'b0;
            alu_op <= 3'b010;// &
            mem_wen <= 1'b0;
            alu_sel <= 1'b0;//sel B
            reg_wen <= 1'b1;
        end
        6'b000101://bne
        begin
            reg_dst <= 1'b0;
            branch <= 1'b1;
            mem_read <= 1'b0;//先写这不知道有没有用
            mem_to_flag <= 1'bX;
            alu_op <= 3'b011;// -
            mem_wen <= 1'b0;
            alu_sel <= 1'b0;//sel B
            reg_wen <= 1'b0;
            sel_ext_type <= 2'b10;//sign
        end
        6'b100011://lw
        begin
            reg_dst <= 1'b0;
            branch <= 1'b0;
            mem_read <= 1'b1;//先写这不知道有没有用
            mem_to_flag <= 1'bX;
            alu_op <= 3'b100;// +
            mem_wen <= 1'b0;
            alu_sel <= 1'b1;//sel offest
            reg_wen <= 1'b1;
            sel_ext_type <= 2'b10;//sign
        end
        6'b101011://sw
        begin
            reg_dst <= 1'b0;
            branch <= 1'b0;
            mem_read <= 1'b0;//先写这不知道有没有用
            mem_to_flag <= 1'bX;
            alu_op <= 3'b001;// +
            mem_wen <= 1'b1;
            alu_sel <= 1'b1;//sel offest
            reg_wen <= 1'b0;
            sel_ext_type <= 2'b10;//sign
        end
        default: begin
            
        end
    endcase
end

    
endmodule