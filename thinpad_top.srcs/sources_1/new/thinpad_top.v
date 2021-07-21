`default_nettype none

module thinpad_top(
    input wire clk_50M,           //50MHz 时钟输入
    input wire clk_11M0592,       //11.0592MHz 时钟输入（备用，可不用）

    input wire clock_btn,         //BTN5手动时钟按钮开关，带消抖电路，按下时为1
    input wire reset_btn,         //BTN6手动复位按钮开关，带消抖电路，按下时为1

    input  wire[3:0]  touch_btn,  //BTN1~BTN4，按钮开关，按下时为1
    input  wire[31:0] dip_sw,     //32位拨码开关，拨到“ON”时为1
    output wire[15:0] leds,       //16位LED，输出时1点亮
    output wire[7:0]  dpy0,       //数码管低位信号，包括小数点，输出1点亮
    output wire[7:0]  dpy1,       //数码管高位信号，包括小数点，输出1点亮
    
    //BaseRAM信号//这个里面放的是指令
    inout wire[31:0] base_ram_data,  //BaseRAM数据，低8位与CPLD串口控制器共享
    output wire[19:0] base_ram_addr, //BaseRAM地址
    output wire[3:0] base_ram_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire base_ram_ce_n,       //BaseRAM片选，低有效
    output wire base_ram_oe_n,       //BaseRAM读使能，低有效
    output wire base_ram_we_n,       //BaseRAM写使能，低有效

    //ExtRAM信号
    inout wire[31:0] ext_ram_data,  //ExtRAM数据
    output wire[19:0] ext_ram_addr, //ExtRAM地址
    output wire[3:0] ext_ram_be_n,  //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire ext_ram_ce_n,       //ExtRAM片选，低有效
    output wire ext_ram_oe_n,       //ExtRAM读使能，低有效
    output wire ext_ram_we_n,       //ExtRAM写使能，低有效

    //直连串口信号
    output wire txd,  //直连串口发送端
    input  wire rxd,  //直连串口接收端

    //Flash存储器信号，参考 JS28F640 芯片手册
    output wire [22:0]flash_a,      //Flash地址，a0仅在8bit模式有效，16bit模式无意义
    inout  wire [15:0]flash_d,      //Flash数据
    output wire flash_rp_n,         //Flash复位信号，低有效
    output wire flash_vpen,         //Flash写保护信号，低电平时不能擦除、烧写
    output wire flash_ce_n,         //Flash片选信号，低有效
    output wire flash_oe_n,         //Flash读使能信号，低有效
    output wire flash_we_n,         //Flash写使能信号，低有效
    output wire flash_byte_n,       //Flash 8bit模式选择，低有效。在使用flash的16位模式时请设为1

    //图像输出信号
    output wire[2:0] video_red,    //红色像素，3位
    output wire[2:0] video_green,  //绿色像素，3位
    output wire[1:0] video_blue,   //蓝色像素，2位
    output wire video_hsync,       //行同步（水平同步）信号
    output wire video_vsync,       //场同步（垂直同步）信号
    output wire video_clk,         //像素时钟输出
    output wire video_de           //行数据有效信号，用于区分消隐区
);

/* =========== Demo code begin =========== */

// PLL分频示例
wire locked, clk_10M, clk_20M;
pll_example clock_gen 
 (
  // Clock in ports
  .clk_in1(clk_50M),  // 外部时钟输入
  // Clock out ports
  .clk_out1(clk_10M), // 时钟输出1，频率在IP配置界面中设置
  .clk_out2(clk_20M), // 时钟输出2，频率在IP配置界面中设置
  // Status and control signals
  .reset(reset_btn), // PLL复位输入
  .locked(locked)    // PLL锁定指示输出，"1"表示时钟稳定，
                     // 后级电路复位信号应当由它生成（见下）
 );



reg reset_of_clk10M;
// 异步复位，同步释放，将locked信号转为后级电路的复位reset_of_clk10M
always@(posedge clk_10M or negedge locked) begin
    if(~locked) reset_of_clk10M <= 1'b1;
    else        reset_of_clk10M <= 1'b0;
end



//没有进行片选前的我自己的top出来的wire类型
wire inst_sram_en_my;
wire [3:0] inst_sram_wen_my;
wire [31:0] inst_sram_addr_my;
wire [31:0] inst_sram_wdata_my;
wire [31:0] inst_sram_rdata_my;
  
wire data_sram_en_my;
wire [3:0] data_sram_wen_my;
wire [31:0] data_sram_addr_my;
wire [31:0] data_sram_wdata_my;
wire [31:0] data_sram_rdata_my;
/*
always@(posedge clk_10M or posedge reset_of_clk10M) begin
    if(reset_of_clk10M)begin
        // Your Code
    end
    else begin
        // Your Code
    end
end
*/
reg  [19:0]base_ram_addr_r;
reg  [3:0]base_ram_be_n_r;
reg  base_ram_ce_n_r;
reg  base_ram_oe_n_r;
reg  base_ram_we_n_r;
reg  [31:0]base_ram_data_r;

reg  [19:0]ext_ram_addr_r;
reg  [3:0]ext_ram_be_n_r;
reg  ext_ram_ce_n_r;
reg  ext_ram_oe_n_r;
reg  ext_ram_we_n_r;
reg  [31:0]ext_ram_data_r;
//RAM->REG
reg [31:0]inst_rdata_r;
reg [31:0]data_rdata_r;
//reg ext_ram_we_n_r;

reg sel_sram;
//  reg from_ex;

top cpu(
    .clk_in(clk_20M),
    .rsten(reset_of_clk10M),

    .inst_sram_en(inst_sram_en_my),
    .inst_sram_wen(inst_sram_wen_my),
    .inst_sram_addr(inst_sram_addr_my),
    .inst_sram_wdata(inst_sram_wdata_my),
    .inst_sram_rdata(inst_sram_rdata_my),
  
    .data_sram_en(data_sram_en_my),
    .data_sram_wen(data_sram_wen_my),
    .data_sram_addr(data_sram_addr_my),
    .data_sram_wdata(data_sram_wdata_my),
    .data_sram_rdata(data_sram_rdata_my)
);
//进行对应片选和真正在芯片上地址对应


always @(*) begin
    if(reset_of_clk10M)begin
            inst_rdata_r <= 32'b0;
            data_rdata_r <= 32'b0;
    end
    else begin          //1:0
        inst_rdata_r <= sel_sram ? base_ram_data : 32'b0; 
        data_rdata_r <= sel_sram ? ( ~ext_ram_oe_n_r ? ext_ram_data : 32'b0 ) : (~base_ram_oe_n_r ? base_ram_data : 32'b0);
       //这还是在从ROM中读取数据             读使能                                   读使能
       //相当于是sel为1时选择extrom做dataRom
                                      //   读                                       读
    end
end
assign inst_sram_rdata_my = inst_rdata_r;
assign data_sram_rdata_my = data_rdata_r;
//REG->RAM  
assign base_ram_data = ~base_ram_we_n_r ? base_ram_data_r : 32'bz;
assign ext_ram_data = ~ext_ram_we_n_r ? ext_ram_data_r : 32'bz;
                      //is 0 -> 1

always @(posedge clk_20M)begin
    if(reset_of_clk10M)begin
        base_ram_addr_r <= 20'b0;
        base_ram_be_n_r <= 4'b0;
        base_ram_ce_n_r <= 1'b1;
        base_ram_oe_n_r <= 1'b1;
        base_ram_we_n_r <= 1'b1;
        base_ram_data_r <= 32'b0;

        ext_ram_addr_r <= 20'b0;
        ext_ram_be_n_r <= 4'b0;
        ext_ram_ce_n_r <= 1'b1;
        ext_ram_oe_n_r <= 1'b1;
        ext_ram_we_n_r <= 1'b1;
        ext_ram_data_r <= 32'b0;

        sel_sram <= 1'b1;
    end
    //开始对data的地址进行仲裁
    else begin
        if(data_sram_en_my &&  data_sram_addr_my >= 32'h0 && data_sram_addr_my <32'h00400000)begin
            //data用baseram
            //让baseram使能
            base_ram_addr_r <= data_sram_addr_my[21:2];
            base_ram_be_n_r <= 4'b0;
            base_ram_ce_n_r <= 1'b0;
            base_ram_oe_n_r <= data_sram_wen_my;
            base_ram_we_n_r <= ~data_sram_wen_my;
            base_ram_data_r <= data_sram_wdata_my;
            //1无效
            ext_ram_addr_r <= 20'b0;
            ext_ram_be_n_r <= 4'b0;
            ext_ram_ce_n_r <= 1'b1;
            ext_ram_oe_n_r <= 1'b1;
            ext_ram_we_n_r <= 1'b1;
            ext_ram_data_r <= 32'b0;

            sel_sram <= 1'b0;
            //from_ex <= 1'b1;
            
        end

        else if(data_sram_en_my && data_sram_addr_my >= 32'h00400000)begin
            //data使用extram(也就是他本身的)
            //让extram使能
            ext_ram_addr_r <= data_sram_addr_my[21:2];
            ext_ram_be_n_r <= 4'b0;
            ext_ram_ce_n_r <= 1'b0;
            ext_ram_oe_n_r <= data_sram_wen_my;
            ext_ram_we_n_r <= ~data_sram_wen_my; //if 1 -> 0
            ext_ram_data_r <= data_sram_wdata_my;
    
            base_ram_addr_r <= inst_sram_addr_my[21:2];
            base_ram_be_n_r <= 4'b0;
            base_ram_ce_n_r <= 1'b0;
            base_ram_oe_n_r <= 1'b0;//读
            base_ram_we_n_r <= 1'b1;
            //from_ex <= 1'b0;

            sel_sram <= 1'b1;
        end else begin
            ext_ram_addr_r <= 20'bZ;//在这将ext的addr赋值成Z
            ext_ram_be_n_r <= 4'b0;
            ext_ram_ce_n_r <= 1'b1;
            ext_ram_oe_n_r <= 1'b1;
            ext_ram_we_n_r <= 1'b1;
            ext_ram_data_r <= data_sram_wdata_my;
            /////////////用写使能判断选哪个数据（1读的/0写的）
            //上面的想法错了，应该对于这个应该是只有写方面的
    
            base_ram_addr_r <= inst_sram_addr_my[21:2];
            base_ram_be_n_r <= 4'b0;
            base_ram_ce_n_r <= 1'b0;
            base_ram_oe_n_r <= 1'b0;//读
            base_ram_we_n_r <= 1'b1;
            //base_ram_data_r <= 32'b0;
            sel_sram <= 1'b1;
            //from_ex <= 1'b0;
        end
    end  
end

//这个才是真正的;
assign base_ram_addr = base_ram_addr_r;
assign base_ram_be_n = base_ram_be_n_r;
assign base_ram_ce_n = base_ram_ce_n_r;
assign base_ram_oe_n = base_ram_oe_n_r;
assign base_ram_we_n = base_ram_we_n_r;


assign ext_ram_addr = ext_ram_addr_r;
assign ext_ram_be_n = ext_ram_be_n_r;
assign ext_ram_ce_n = ext_ram_ce_n_r;
assign ext_ram_oe_n = ext_ram_oe_n_r;
assign ext_ram_we_n = ext_ram_we_n_r;

// 不使用内存、串口时，禁用其使能信号
//之前被下面这个东西坑了
/*assign base_ram_ce_n = 1'b1;
assign base_ram_oe_n = 1'b1;
assign base_ram_we_n = 1'b1;

assign ext_ram_ce_n = 1'b1;
assign ext_ram_oe_n = 1'b1;
assign ext_ram_we_n = 1'b1;

// 数码管连接关系示意图，dpy1同理
// p=dpy0[0] // ---a---
// c=dpy0[1] // |     |
// d=dpy0[2] // f     b
// e=dpy0[3] // |     |
// b=dpy0[4] // ---g---
// a=dpy0[5] // |     |
// f=dpy0[6] // e     c
// g=dpy0[7] // |     |
//           // ---d---  p

/*/
////// 7段数码管译码器演示，将number用16进制显示在数码管上面
/*wire[7:0] number;
SEG7_LUT segL(.oSEG1(dpy0), .iDIG(number[3:0])); //dpy0是低位数码管
SEG7_LUT segH(.oSEG1(dpy1), .iDIG(number[7:4])); //dpy1是高位数码管
//直连串口接收发送演示，从直连串口收到的数据再发送出去
wire [7:0] ext_uart_rx;
reg  [7:0] ext_uart_buffer, ext_uart_tx;
wire ext_uart_ready, ext_uart_clear, ext_uart_busy;
reg ext_uart_start, ext_uart_avai;
    
assign number = ext_uart_buffer;
*/

/*
async_receiver #(.ClkFrequency(50000000),.Baud(9600)) //接收模块，9600无检验位
    ext_uart_r(
        .clk(clk_50M),                       //外部时钟信号
        .RxD(rxd),                           //外部串行信号输入
        .RxD_data_ready(ext_uart_ready),  //数据接收到标志
        .RxD_clear(ext_uart_clear),       //清除接收标志
        .RxD_data(ext_uart_rx)             //接收到的一字节数据
    );

assign ext_uart_clear = ext_uart_ready; //收到数据的同时，清除标志，因为数据已取到ext_uart_buffer中
always @(posedge clk_50M) begin //接收到缓冲区ext_uart_buffer
    if(ext_uart_ready)begin
        ext_uart_buffer <= ext_uart_rx;
        ext_uart_avai <= 1;
    end else if(!ext_uart_busy && ext_uart_avai)begin 
        ext_uart_avai <= 0;
    end
end
always @(posedge clk_50M) begin //将缓冲区ext_uart_buffer发送出去
    if(!ext_uart_busy && ext_uart_avai)begin 
        ext_uart_tx <= ext_uart_buffer;
        ext_uart_start <= 1;
    end else begin 
        ext_uart_start <= 0;
    end
end

async_transmitter #(.ClkFrequency(50000000),.Baud(9600)) //发送模块，9600无检验位
    ext_uart_t(
        .clk(clk_50M),                  //外部时钟信号
        .TxD(txd),                      //串行信号输出
        .TxD_busy(ext_uart_busy),       //发送器忙状态指示
        .TxD_start(ext_uart_start),    //开始发送信号
        .TxD_data(ext_uart_tx)        //待发送的数据
    );*/
/*
//图像输出演示，分辨率800x600@75Hz，像素时钟为50MHz
wire [11:0] hdata;
assign video_red = hdata < 266 ? 3'b111 : 0; //红色竖条
assign video_green = hdata < 532 && hdata >= 266 ? 3'b111 : 0; //绿色竖条
assign video_blue = hdata >= 532 ? 2'b11 : 0; //蓝色竖条
assign video_clk = clk_50M;
vga #(12, 800, 856, 976, 1040, 600, 637, 643, 666, 1, 1) vga800x600at75 (
    .clk(clk_50M), 
    .hdata(hdata), //横坐标
    .vdata(),      //纵坐标
    .hsync(video_hsync),
    .vsync(video_vsync),
    .data_enable(video_de)
);
/* =========== Demo code end =========== */






endmodule
