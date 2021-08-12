module MEMtest (
    input rst,
    input clk,

    input data_rom_en,
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
    reg[31:0] ext_ram_addr; //ExtRAM地址
    //reg[3:0] ext_ram_be_n; //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
    reg ext_ram_ce_n; //ExtRAM片选，低有效
    reg ext_ram_oe_n; //ExtRAM读使能，低有效
    reg ext_ram_we_n; //ExtRAM写使能，低有效

reg [2:0]  state;
reg [31:0]olddata;
reg [31:0]oldaddr;
reg [31:0]oldolddata;


always @(posedge clk) begin
    if(rst)begin
        ext_ram_data<=32'd0;
        ext_ram_addr<=20'd0;
        //ext_ram_be_n=4'b0;
        ext_ram_ce_n<=1'b1;
        ext_ram_oe_n<=1'b1;
        ext_ram_we_n<=1'b1;
        olddata <= 32'h000000002;
        oldaddr <= 32'h00000;
        state<=3'b000;
        stall <=1'b0;
        oldolddata <= 000000001;
    end else begin
        if(oldaddr != data_rom_addr || olddata != data_rom_wdata) begin
            case(state)
                3'b000:begin
                    ext_ram_addr <=oldaddr;
                    //ext_ram_ce_n<= ~data_rom_en;
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
                    //ext_ram_ce_n<=~data_rom_en;
                    ext_ram_ce_n <= 1'b1;
                    ext_ram_we_n<=1'b1;
                    state <= state + 3'b001;
                end
                3'b100:begin
                    //oldaddr <= data_rom_addr;
                    oldaddr <= oldaddr + 4'h4;
                    //olddata <= data_rom_wdata;
                    oldolddata <= olddata;
                    olddata <= oldolddata + olddata;
                    //olddata <= 32'h00000006;
                    ext_ram_addr <=oldaddr;
                    state <= 3'b000;
                end
            endcase
            if(ext_ram_addr >= 24'h3fffff)begin
                ext_ram_addr <= 24'h3fffff;
            end
        end
    end
end

assign     wext_ram_data = ext_ram_data;  //ExtRAM数据
assign     wext_ram_addr = ext_ram_addr[21:2];
//assign     wext_ram_be_n =ext_ram_be_n;
assign     wext_ram_ce_n=ext_ram_ce_n;
assign     wext_ram_oe_n=ext_ram_oe_n;
assign     wext_ram_we_n=ext_ram_we_n;

    
endmodule