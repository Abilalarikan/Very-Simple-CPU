`timescale 1ns / 1ns

module tb;
parameter SIZE = 14, DEPTH = 1024;

reg clk;
initial begin
  clk = 1;
  forever
	  #5 clk = ~clk;
end

reg rst;
initial begin
	rst = 1;
	repeat (20) @(posedge clk);
	rst <= #1 0;
	repeat (400) @(posedge clk);
	$display("the maximum number between the numbers %d, %d, %d, %d, %d, %d, %d, %d, %d, %d  is %d.", 
	inst_blram.memory[500],inst_blram.memory[501],inst_blram.memory[502],inst_blram.memory[503],
	inst_blram.memory[504],inst_blram.memory[505],inst_blram.memory[506],inst_blram.memory[507],
	inst_blram.memory[508],inst_blram.memory[509],inst_blram.memory[600]);
	$finish;
end

wire wrEn;
wire [SIZE-1:0] addr_toRAM;
wire [31:0] data_toRAM, data_fromRAM;

VerySimpleCPU inst_VerySimpleCPU(
  .clk(clk),
  .rst(rst),
  .wrEn(wrEn),
  .data_fromRAM(data_fromRAM),
  .addr_toRAM(addr_toRAM),
  .data_toRAM(data_toRAM)
);

blram #(SIZE, DEPTH) inst_blram(
  .clk(clk),
  .rst(rst),
  .i_we(wrEn),
  .i_addr(addr_toRAM),
  .i_ram_data_in(data_toRAM),
  .o_ram_data_out(data_fromRAM)
);

endmodule

module blram(clk, rst, i_we, i_addr, i_ram_data_in, o_ram_data_out);

parameter SIZE = 10, DEPTH = 1024;

input clk;
input rst;
input i_we;
input [SIZE-1:0] i_addr;
input [31:0] i_ram_data_in;
output reg [31:0] o_ram_data_out;

reg [31:0] memory[0:DEPTH-1];

always @(posedge clk) begin
  o_ram_data_out <= #1 memory[i_addr[SIZE-1:0]];
  if (i_we)
		memory[i_addr[SIZE-1:0]] <= #1 i_ram_data_in;
end 
///////////////
//0: CPi 599 500
//1: CP 602 597
//2: LTi 602 10
//3: BZJ  601 602
//4: ADDi 597 1
//5: CPI 598 599
//6: CP  603 598
//7: LT 603 600
//8: BZJ 604 603
//9: ADDi 599 1
//10: BZJi 596 1
//11: CP 600 598
//12: ADDi 599 1
//13: BZJi 596 1
//14: ADDi 596 1
//500: 28         //ARRAY
//501: 17			// E
//502: 36			// L
//503: 45			// E
//504: 58			// E
//505: 91			// M
//506: 6				// E
//507: 711			// N
//508: 24			// T
//509: 402			// S
//596: 0
//597: 0
//598: 0
//599: 0
//600: 0				//MAX NUMBER
//601: 14
//602: 0
//603: 0
//604: 11

initial begin
	memory[0] = 32'h9095c1f4;
	memory[1] = 32'h80968255;
	memory[2] = 32'h7096800a;
	memory[3] = 32'hc096425a;
	memory[4] = 32'h10954001;
	memory[5] = 32'ha0958257;
	memory[6] = 32'h8096c256;
	memory[7] = 32'h6096c258;
	memory[8] = 32'hc097025b;
	memory[9] = 32'h1095c001;
	memory[10] = 32'hd0950001;
	memory[11] = 32'h80960256;
	memory[12] = 32'h1095c001;
	memory[13] = 32'hd0950001;
	memory[14] = 32'h10950001;
	memory[500] = 32'h1c;
	memory[501] = 32'h11;
	memory[502] = 32'h24;
	memory[503] = 32'h2d;
	memory[504] = 32'h3a;
	memory[505] = 32'h5b;
	memory[506] = 32'h6;
	memory[507] = 32'h2c7;
	memory[508] = 32'h18;
	memory[509] = 32'h192;
	memory[596] = 32'h0;
	memory[597] = 32'h0;
	memory[598] = 32'h0;
	memory[599] = 32'h0;
	memory[600] = 32'h0;
	memory[601] = 32'he;
	memory[602] = 32'h0;
	memory[603] = 32'h0;
	memory[604] = 32'hb;

end
endmodule
