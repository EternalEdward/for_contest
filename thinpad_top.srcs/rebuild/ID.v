module ID (
    input wire rst,

    input wire [31:0]inst_i,
    input wire [31:0]pc_i, 

    output reg stallreq_o,


    output wire [31:0]inst_o,

//前推
//  from exe
    input wire exe_w_reg_en_i,
    input wire [31:0]exe_reg_wdata_i,
    input wire [4:0]exe_reg_waddr_i,

// from mem 
    input wire mem_w_reg_en_i,
    input wire [31:0]mem_reg_wdata_i,
    input wire [4:0]mem_reg_waddr_i,

    output reg[7:0]alu_op_o,
    output reg[2:0]alu_sel_o,

////////////////////////////////////////////////
//this has give the reg
    output reg [4:0]read_reg_addr1_o,
    output reg [4:0]read_reg_addr2_o,
    output reg read_reg1_en,
    output reg read_reg2_en,

    output reg [4:0]w_reg_addr_o,
    output reg w_reg_en,

    input wire [31:0]read_reg_data1_i,
    input wire [31:0]read_reg_data2_i,

//LW
    input wire [31:0]new_data_lw_o,
    input wire lw_flag_i,

    //延迟槽
    input delay_cao_en_i,
    output reg next_inst_delay_o,
    output reg branch_en_o,
    output reg [31:0]branch_target_addr_o,
    output reg [31:0]link_addr_o,
    output reg delay_cao_en_o,

    output reg [31:0]caseA_o,
    output reg [31:0]caseB_o
);
/*
	    31-26	25-21	20-16	11-15	10-6	5-0
ori	    001101	rs	    rt	          imm(16)		
lui	    001111	00000	rt	          imm(16)		
addu	000000	rs	    rt	      rd	00000	100001
bne	    000101	rs	    rt	        offset		
lw	    100011	base	rt	        offset		
sw	    101011	base	rt	        offset		
*/
wire [31:0] offest_after_LL2;
wire [31:0] pc_plus_4;//第二个
wire [31:0] pc_plus_8;//next

assign pc_plus_4 = pc_i + 4;
assign pc_plus_8 = pc_i + 8;
assign offest_after_LL2 = {{14{inst_i[15]}},inst_i[15:0],2'b00};
assign inst_o = inst_i;

reg [31:0]imm_after_ext;
reg youxiao;
always @(*) begin
    if(rst)begin
        alu_op_o <= 8'b00000000;
        alu_sel_o <= 3'b000;

        read_reg1_en <= 1'b0;
        read_reg2_en <= 1'b0;

        read_reg_addr1_o <= 5'b00000;
        read_reg_addr2_o <= 5'b00000;

        w_reg_en <= 1'b0;
        w_reg_addr_o <= 5'b00000;

        //caseA_o <= 32'h00000000;
        //caseB_o <= 32'h00000000;

        imm_after_ext <= 32'h00000000;
        youxiao <= 1'b0;

        branch_en_o <= 1'b0;
        link_addr_o <= 32'h00000000;
        branch_target_addr_o <= 32'h00000000;
        //delay_cao_en_o <= 1'b0;
        next_inst_delay_o <= 1'b0;
        stallreq_o <= 1'b0;

    end else begin
        youxiao <= 1'b0;
        alu_op_o <= 8'b00000000;
        alu_sel_o <= 3'b000;

        read_reg1_en <= 1'b0;
        read_reg2_en <= 1'b0;

        read_reg_addr1_o <= inst_i[25:21];
        read_reg_addr2_o <= inst_i[20:16];

        w_reg_en <= 1'b0;
        w_reg_addr_o <= inst_i[15:11];

        imm_after_ext <= 32'h00000000;

        branch_en_o <= 1'b0;
        link_addr_o <= 32'h00000000;
        branch_target_addr_o <= 32'h00000000;
        delay_cao_en_o <= 1'b0;
        next_inst_delay_o <= 1'b0;

        stallreq_o <= 1'b0;

        case (inst_i[31:26])//op
            6'b000000: begin//
                case (inst_i[10:6])//op2
                    5'b00000:begin//逻辑运算指令 不带imm的
                        case (inst_i[5:0])//op3
                            6'b100101:begin//OR //1
                                read_reg1_en <= 1'b1;
                                read_reg2_en <= 1'b1; 
                                w_reg_en <= 1'b1;
                                alu_op_o <= 8'b00000001; //|
                                alu_sel_o <= 3'b001;
                                youxiao <= 1'b1;
                            end

                            6'b100100:begin//AND //2
                                read_reg1_en <= 1'b1;
                                read_reg2_en <= 1'b1; 
                                w_reg_en <= 1'b1;
                                alu_op_o <= 8'b00000010; //&
                                alu_sel_o <= 3'b001;
                                youxiao <= 1'b1;
                            end
                            
                            6'b100110:begin//XOR //3
                                read_reg1_en <= 1'b1;
                                read_reg2_en <= 1'b1; 
                                w_reg_en <= 1'b1;
                                alu_op_o <= 8'b00000100; //异或
                                alu_sel_o <= 3'b001;
                                youxiao <= 1'b1;
                            end

                            //算数运算ADDU
                            6'b100001: begin//ADDU
                                read_reg1_en <= 1'b1;
                                read_reg2_en <= 1'b1; 
                                w_reg_en <= 1'b1;
                                alu_op_o <= 8'b11000001; //ADD
                                alu_sel_o <= 3'b100;
                                youxiao <= 1'b1;
                            end

                            //
                            6'b001000: begin//JR
                                read_reg1_en <= 1'b1;
                                read_reg2_en <= 1'b0; 
                                w_reg_en <= 1'b0;
                                alu_op_o <= 8'b11100001; //JR
                                alu_sel_o <= 3'b110;// sel jump
                                youxiao <= 1'b1;
                                link_addr_o <= 32'h00000000;
                                branch_en_o <= 1'b1;
                                next_inst_delay_o <= 1'b1;
                                branch_target_addr_o <= caseA_o;
                            end

                            default: begin
                            end
                        endcase
                    end
                    default: begin
                    end
                endcase
            end

            6'b001101: begin//ORI //4
                alu_op_o <= 8'b00000001;//OR
                alu_sel_o <= 3'b001;// logic
                

                read_reg1_en <= 1'b1;
                read_reg2_en <= 1'b0;

                //read_reg_addr1_o <= inst_i[25:21];
                
                imm_after_ext <= {16'h0,inst_i[15:0]};

                w_reg_en <= 1'b1;
                w_reg_addr_o <= inst_i[20:16];

                youxiao <= 1'b1;
            end

            6'b001100: begin//ANDI //5
                alu_op_o <= 8'b00000010;//AND
                alu_sel_o <= 3'b001;// logic
                

                read_reg1_en <= 1'b1;
                read_reg2_en <= 1'b0;

                //read_reg_addr1_o <= inst_i[25:21];
                
                imm_after_ext <= {16'h0,inst_i[15:0]};

                w_reg_en <= 1'b1;
                w_reg_addr_o <= inst_i[20:16];

                youxiao <= 1'b1;
            end

            6'b001111: begin//LUI //6
                alu_op_o <= 8'b00000001;//OR
                alu_sel_o <= 3'b001;// logic
                
                read_reg1_en <= 1'b1;
                read_reg2_en <= 1'b0;

                //read_reg_addr1_o <= inst_i[25:21];
                
                imm_after_ext <= {inst_i[15:0],16'h0};

                w_reg_en <= 1'b1;
                w_reg_addr_o <= inst_i[20:16];

                youxiao <= 1'b1;
            end

            6'b001110: begin//XORI //7
                alu_op_o <= 8'b00000100;//XOR
                alu_sel_o <= 3'b001;// logic

                read_reg1_en <= 1'b1;
                read_reg2_en <= 1'b0;

                //read_reg_addr1_o <= inst_i[25:21];
                
                imm_after_ext <= {16'h0,inst_i[15:0]};

                w_reg_en <= 1'b1;
                w_reg_addr_o <= inst_i[20:16];

                youxiao <= 1'b1;
            end//逻辑运算结束于此

            6'b001001:begin//AUUIU
                alu_op_o <= 8'b11000001;//ADD
                alu_sel_o <= 3'b100;//arth

                read_reg1_en <= 1'b1;
                read_reg2_en <= 1'b0;

                //read_reg_addr1_o <= inst_i[25:21];
                
                imm_after_ext <= {{16{inst_i[15]}},inst_i[15:0]};

                w_reg_en <= 1'b1;
                w_reg_addr_o <= inst_i[20:16];

                youxiao <= 1'b1;
            end
            
            6'b011100: begin//MUL
                alu_op_o <= 8'b11000010;//MUX
                alu_sel_o <= 3'b100;//arth

                read_reg1_en <= 1'b1;
                read_reg2_en <= 1'b0;

                //read_reg_addr1_o <= inst_i[25:21];
                
                imm_after_ext <= {{16{inst_i[15]}},inst_i[15:0]};

                w_reg_en <= 1'b1;
                w_reg_addr_o <= inst_i[20:16];

                youxiao <= 1'b1;
            end

            6'b000010: begin // J
                read_reg1_en <= 1'b0;
                read_reg2_en <= 1'b0; 
                w_reg_en <= 1'b0;
                alu_op_o <= 8'b11100010; //J
                alu_sel_o <= 3'b110;// sel jump
                youxiao <= 1'b1;
                link_addr_o <= 32'h00000000;
                branch_en_o <= 1'b1;
                next_inst_delay_o <= 1'b1; 
                branch_target_addr_o <= {pc_plus_4[31:28],inst_i[25:0],2'b00};
            end

            6'b000011: begin//JAL
                read_reg1_en <= 1'b0;
                read_reg2_en <= 1'b0; 
                w_reg_en <= 1'b0;
                alu_op_o <= 8'b11100100; //J
                alu_sel_o <= 3'b110;// sel jump
                youxiao <= 1'b1;
                link_addr_o <= pc_plus_8;//注意
                branch_en_o <= 1'b1;
                next_inst_delay_o <= 1'b1; 
                branch_target_addr_o <= {pc_plus_4[31:28],inst_i[25:0],2'b00};    
            end

            6'b000100: begin//BEQ
                read_reg1_en <= 1'b1;
                read_reg2_en <= 1'b1; 
                w_reg_en <= 1'b0;

                alu_op_o <= 8'b11100101; //BEQ
                alu_sel_o <= 3'b110;// sel jump
                youxiao <= 1'b1;
                if(caseA_o == caseB_o)begin
                    branch_en_o <= 1'b1;
                    next_inst_delay_o <= 1'b1;
                    branch_target_addr_o <= pc_plus_4 + offest_after_LL2; 
                end
                //link_addr_o <= pc_plus_8;//注意
            end

            6'b000101: begin//BNE
                read_reg1_en <= 1'b1;
                read_reg2_en <= 1'b1; 
                w_reg_en <= 1'b0;

                alu_op_o <= 8'b11100110; //BEQ
                alu_sel_o <= 3'b110;// sel jump
                youxiao <= 1'b1;
                if(lw_flag_i)begin
                    if (caseA_o != new_data_lw_o) begin
                        branch_en_o <= 1'b1;
                        next_inst_delay_o <= 1'b1;
                        branch_target_addr_o <= pc_plus_4 + offest_after_LL2;  
                    end
                end else begin
                   if(caseA_o != caseB_o)begin
                        branch_en_o <= 1'b1;
                        next_inst_delay_o <= 1'b1;
                        branch_target_addr_o <= pc_plus_4 + offest_after_LL2; 
                    end 
                end
            end
                
            6'b000111: begin//BGTZ
                read_reg1_en <= 1'b1;
                read_reg2_en <= 1'b0; 
                w_reg_en <= 1'b0;

                alu_op_o <= 8'b11100111; //BGTZ
                alu_sel_o <= 3'b110;// sel jump
                youxiao <= 1'b1;
                link_addr_o <= pc_plus_8;//注意
                if((caseA_o[31] == 1'b1) || (caseA_o == 32'h00000000))begin
                    branch_en_o <= 1'b1;
                    next_inst_delay_o <= 1'b1;
                    branch_target_addr_o <= pc_plus_4 + offest_after_LL2; 
                end
            end

            6'b100011: begin//LW
                read_reg1_en <= 1'b1;
                read_reg2_en <= 1'b0; 
                w_reg_en <= 1'b1;
                w_reg_addr_o <= inst_i[20:16];
                alu_op_o <= 8'b11110001; //LW
                alu_sel_o <= 3'b111;// sel ROM的
                youxiao <= 1'b1;
                stallreq_o <=1'b1;
            end

            6'b101011: begin//SW
                read_reg1_en <= 1'b1;
                read_reg2_en <= 1'b1; 
                w_reg_en <= 1'b0;
                //w_reg_addr_o <= inst_i[20:16];
                alu_op_o <= 8'b11110010; //SW
                alu_sel_o <= 3'b111;// sel ROM的
                youxiao <= 1'b1;
                stallreq_o <= 1'b1;
            end

            default: begin
            end
        endcase 

        if(inst_i[31:21] == 11'b00000000000) begin//移位指令
            case (inst_i[5:0])
                5'b000000: begin//SLL
                    alu_op_o <= 8'b10000001;//SLL
                    alu_sel_o <= 3'b010;// S?L
                    
                    branch_en_o <= 1'b0;

                    read_reg1_en <= 1'b0;
                    read_reg2_en <= 1'b1;

                    //read_reg_addr1_o <= inst_i[25:21];
                    
                    imm_after_ext[4:0] <= inst_i[10:6];

                    w_reg_en <= 1'b1;
                    w_reg_addr_o <= inst_i[15:11];

                    youxiao <= 1'b1;
                end
                5'b000010: begin//SRL
                    alu_op_o <= 8'b10000010;//SRL
                    alu_sel_o <= 3'b010;// S?L
                    
                    branch_en_o <= 1'b0;

                    read_reg1_en <= 1'b0;
                    read_reg2_en <= 1'b1;

                    //read_reg_addr1_o <= inst_i[25:21];
                    
                    imm_after_ext[4:0] <= inst_i[10:6];

                    w_reg_en <= 1'b1;
                    w_reg_addr_o <= inst_i[15:11];

                    youxiao <= 1'b1;
                end
                default: begin
                end
            endcase
        end
    end
end

always @(*) begin
    if(rst)begin
        caseA_o <= 32'h00000000;
    end else begin
        if(read_reg1_en == 1'b1 && exe_w_reg_en_i == 1'b1 && exe_reg_wdata_i == read_reg_addr1_o)begin
            caseA_o <= exe_reg_wdata_i;
        end else begin
            if(read_reg1_en == 1'b1 && mem_w_reg_en_i == 1'b1 && mem_reg_waddr_i == read_reg_addr1_o)begin    
                caseA_o <= mem_reg_wdata_i;
            end else begin
                caseA_o <= (read_reg1_en == 1'b1) ? read_reg_data1_i : 
                            (read_reg1_en == 1'b0) ? imm_after_ext    :
                                                32'h00000000;
            end 
        end                    
    end
end

always @(*) begin
    if(rst)begin
        caseB_o <= 32'h00000000;
    end else begin
        if(read_reg2_en == 1'b1 && exe_w_reg_en_i == 1'b1 && exe_reg_wdata_i == read_reg_addr2_o)begin
            caseB_o <= exe_reg_wdata_i;
        end else begin
            if(read_reg2_en == 1'b1 && mem_w_reg_en_i == 1'b1 && mem_reg_waddr_i == read_reg_addr2_o)begin    
                caseB_o <= mem_reg_wdata_i;
            end else begin
                caseB_o <= (read_reg2_en == 1'b1) ? read_reg_data2_i : 
                            (read_reg2_en == 1'b0) ? imm_after_ext    :
                                                32'h00000000;
            end 
        end                    
    end
end

always @(*) begin
    if (rst) begin
        delay_cao_en_o <= 1'b0;
    end else begin
        delay_cao_en_o <= delay_cao_en_i;
    end
end

endmodule