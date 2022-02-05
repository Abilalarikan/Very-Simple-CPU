`timescale 1ns / 1ps

module VerySimpleCPU(clk,rst,data_fromRAM,wrEn,addr_toRAM,data_toRAM);

parameter SIZE  = 14;

input clk,rst;
input wire [31:0] data_fromRAM;
output reg wrEn;
output reg [SIZE-1:0] addr_toRAM;
output reg [31:0] data_toRAM;

reg [3:0] state_current, state_next;
reg[SIZE-1:0] pc_current , pc_next ; 
reg[31:0] iw_current , iw_next ;
reg[31:0] r1_current , r1_next ;
reg[31:0] r2_current , r2_next;

always@(posedge clk)begin 
	if(rst)begin
		state_current <= 0; 
		pc_current <= 14'b0 ; 
		iw_current <= 32'b0 ; 
		r1_current <= 32'b0 ; 
		r2_current <= 32'b0 ;
	end 
	else begin
		state_current <= state_next ; 
		pc_current  	<= pc_next ;
		iw_current  	<= iw_next ; 
		r1_current 		<= r1_next ;
		r2_current 		<= r2_next ;
	end 
end
always@(*)begin
	state_next = state_current ; 
	pc_next  =  pc_current ; 
	iw_next =   iw_current  ; 
	r1_next =  r1_current ; 
	r2_next = r2_current ;
	wrEn = 0;
	addr_toRAM = 0;
	data_toRAM = 0; 
	case(state_current)
		0:begin
			pc_next = 0;
			iw_next = 0;
			r1_next = 0;
			r2_next = 0;
			state_next = 1; 
		end
		1:begin
			addr_toRAM = pc_current ;
			state_next = 2;
		end 
		2:begin
			iw_next = data_fromRAM; 
			casex(data_fromRAM[31:28])
				default:begin
					pc_next = pc_current ; 
					state_next = 1;
				end 
				{3'b10X,1'b0}:begin
					addr_toRAM=data_fromRAM[13:0] ;
					state_next = 3;
				end
				{3'b100,1'b1} : begin
					state_next = 3;
				end 
				{3'bXXX,1'bX}: begin
					addr_toRAM = data_fromRAM[27:14];
					state_next = 3;
				end
			endcase
		end 
		3:begin
			casex(iw_current[31:28])
				 {3'b101,1'bX}: begin
					 r1_next = data_fromRAM ;
					 if(iw_current[28])
						addr_toRAM=iw_current[13:0];
					 else 
						addr_toRAM=r1_next;
				end
				 {3'b100,1'b0}:begin
				 r1_next=data_fromRAM;
				end
				 {3'bXXX,1'b1} : begin 
					r1_next = data_fromRAM ;
					r2_next=iw_current[13:0];
				end
				{3'bXXX,1'b0} : begin 
					r1_next = data_fromRAM ;
					addr_toRAM=iw_current[13:0];
				end
			endcase
			state_next = 4;
		end 
		4:begin
			addr_toRAM = iw_current[27:14];
			//$display("pc:%d",pc_current);
			case(iw_current[31:28])
				{3'b000,1'b0}:begin 
					data_toRAM = data_fromRAM + r1_current ;  //ADD
				end
				{3'b000,1'b1}:begin 
					data_toRAM = r2_current+ r1_current ;  //ADDi
				end
				{3'b001,1'b0}:begin 
					data_toRAM = ~(data_fromRAM & r1_current) ;  //NAND
				end
				{3'b001,1'b1}:begin 
					data_toRAM = ~(r2_current & r1_current) ;  //NANDi
				end
				{3'b010,1'b0}:begin 
					data_toRAM = (data_fromRAM  < 32) ? ( r1_current>> data_fromRAM ) : (r1_current << (data_fromRAM -32)) ; //SRL
				end
				{3'b010,1'b1}:begin 
					data_toRAM = (iw_current[13:0]  < 32) ? ( r1_current>> iw_current[13:0] ) : (r1_current << (iw_current[13:0] -32)) ;  //SRLi
				end
				{3'b011,1'b0}:begin 
					data_toRAM = (r1_current < data_fromRAM) ? 1 : 0 ;  //LT
				end
				{3'b011,1'b1}:begin 
					data_toRAM = (r1_current < iw_current[13:0]) ? 1 : 0 ;   //LTi
				end
				{3'b111,1'b0}:begin 
					data_toRAM = (r1_current* data_fromRAM) ;  //MUL
				end
				{3'b111,1'b1}:begin 
					data_toRAM = (r1_current* iw_current[13:0]) ;  //MULi
				end
				{3'b100,1'b0} :begin 
					data_toRAM = r1_current;  //CP
				end
				{3'b100,1'b1}:begin 
					data_toRAM = iw_current[13:0];  //CPi 
				end
				{3'b101,1'b0} :begin 
					data_toRAM = data_fromRAM;  //CPI
				end
				{3'b101,1'b1}:begin 
					addr_toRAM=r1_current;
					data_toRAM = data_fromRAM ; //CPIi
				end
				{3'b110,1'b0}:begin 
					r2_next=data_fromRAM;
					pc_next = (r2_next == 0) ? r1_current : (pc_current + 1); //BZJ 
					state_next=1;
				end
				{3'b110,1'b1}:begin 
					pc_next = r2_current+r1_current; //BZJi
					state_next=1;
				end
			endcase
			if(iw_current[31:28]!=4'b1100 && iw_current[31:28]!=4'b1101) begin
				state_next = 1;
				pc_next = pc_current + 1'b1 ;
				wrEn = 1;
			end
		end
		endcase
	end
endmodule


