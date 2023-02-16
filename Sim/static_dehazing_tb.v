`timescale 1ns/1ns

module static_dehazing_tb;

  // Parameters
defparam static_dehazing_dut.u1.system_clock = 50000 ;//重定义 defparam,用于修改参数,缩短仿真时间

  // Ports
  reg  board_clk = 0;
  reg  rx = 0;
  reg  sys_rst_n = 0;
  wire  hsync;
  wire  vsync;
  wire [7:0] rgb_red;
  wire [7:0] rgb_green;
  wire [7:0] rgb_blue;
  wire  [23:0] dark_ch_pic;
  wire  vga_driver_clk;
  wire  rgb_blk;

  static_dehazing static_dehazing_dut 
  (
    .board_clk      (board_clk ),
    .rx             (rx ),
    .sys_rst_n      (sys_rst_n ),
    .hsync          (hsync ),
    .vsync          (vsync ),
    .rgb_red        (rgb_red ),
    .rgb_green      (rgb_green ),
    .rgb_blue       (rgb_blue ),
    .dark_ch_pic    (dark_ch_pic),
    .vga_driver_clk (vga_driver_clk ),
    .rgb_blk        ( rgb_blk)
  );


reg [7:0] data_mem[16383:0] ;//数据深度（个数）

//读取数据
initial
$readmemh("D:/HaoGuojun/MyProject/FPGAProject/Graduation_Prj/static_dehazing/Doc/RGB332_mode.txt",data_mem);

//生成时钟和复位信号
initial
    begin
        sys_rst_n <= 1'b0;
        #100
        sys_rst_n <= 1'b1;
    end
 
 always #5 board_clk = ~board_clk;
 
//rx 赋初值,调用 rx_byte
initial
    begin
        rx <= 1'b1;
        #20
        rx_byte();
    end
 
//rx_byte
task rx_byte();
    integer j;
    for(j=0;j<16384;j=j+1)
        rx_bit(data_mem[j]);
endtask
 
 //rx_bit
 task rx_bit(input[7:0] data);//data 是 data_mem[j]的值。
 integer i;
    for(i=0;i<10;i=i+1)
 begin
    case(i)
        0: rx <= 1'b0; //起始位
        1: rx <= data[0];
        2: rx <= data[1];
        3: rx <= data[2];
        4: rx <= data[3];
        5: rx <= data[4];
        6: rx <= data[5];
        7: rx <= data[6];
        8: rx <= data[7]; //上面 8 个发送的是数据位
        9: rx <= 1'b1; //停止位
    endcase
    #(5*10);//(500000/9600)*5ns*2
 end
 endtask


 endmodule