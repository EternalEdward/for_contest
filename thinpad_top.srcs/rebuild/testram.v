    
    
module MEMtest (
    input rst,
    input clk,

    //input data_rom_en,
    input data_rom_wen,
    input [31:0]data_rom_addr,
    input [31:0]data_rom_wdata,
    //output data_rom_rdata(data_sram_rdata_my),
    

    inout wire[31:0] wext_ram_data,  //ExtRAM数据
    output wire[19:0] wext_ram_addr, //ExtRAM地址
    //output wire[3:0] wext_ram_be_n,  //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire wext_ram_ce_n,       //ExtRAM片选，低有效
    output wire wext_ram_oe_n,       //ExtRAM读使能，低有效
    output wire wext_ram_we_n,       //ExtRAM写使能，低有效
    output reg stall
);


    reg[31:0] ext_ram_data;  //ExtRAM数据
    reg[19:0] ext_ram_addr; //ExtRAM地址
    //reg[3:0] ext_ram_be_n; //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
    reg ext_ram_ce_n; //ExtRAM片选，低有效
    reg ext_ram_oe_n; //ExtRAM读使能，低有效
    reg ext_ram_we_n; //ExtRAM写使能，低有效

reg [7:0]  count;
reg [2:0]  state;
reg t;
reg [31:0]olddata;
always @(*) begin
    if(rst)begin
         t <= 1'b1;
    end else begin
        if(data_rom_wen)begin
            t <= 1'b1;
        end
    end
end

always @(posedge clk) begin
    if(rst)begin
        ext_ram_data<=32'd0;
        ext_ram_addr<=20'd0;
        //ext_ram_be_n=4'b0;
        ext_ram_ce_n<=1'b1;
        ext_ram_oe_n<=1'b1;
        ext_ram_we_n<=1'b1;
        count<=8'd0;
        state<=3'b000;
        stall <=1'b0;
    end else begin
        stall <=1'b0;
        if(t) begin
            //stall <= 1'b1;
            count <= count +1'b1;
            olddata = data_rom_wdata;
            case(state)
                3'b000:begin
                    ext_ram_ce_n<=1'b1;
                    ext_ram_we_n<=1'b1;
                    state <= state + 3'b001;
                end
                3'b001:begin
                    ext_ram_we_n<=1'b0;
                    ext_ram_ce_n<=1'b0;
                    state <= state + 3'b001;
                end
                3'b010:begin
                    ext_ram_data <= olddata;
                    state <= state + 3'b001;
                end
                3'b011:begin
                    ext_ram_ce_n<=1'b1;
                    ext_ram_we_n<=1'b1;
                    state <= state + 3'b001;
                end
                3'b100:begin
                    ext_ram_addr <=data_rom_addr;
                    t <= 1'b1;
                    state <= 3'b000;
                end
        endcase
    end
    end
end

assign     wext_ram_data = ext_ram_data;  //ExtRAM数据
assign     wext_ram_addr = ext_ram_addr;
//assign     wext_ram_be_n =ext_ram_be_n;
assign     wext_ram_ce_n=ext_ram_ce_n;
assign     wext_ram_oe_n=ext_ram_oe_n;
assign     wext_ram_we_n=ext_ram_we_n;

    
endmodule

    
