`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:21:05 03/06/2019 
// Design Name: 
// Module Name:    Assignment2 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

//Main module
module MainModule( input clk, input reset, input [5:0] opCode , input [5:0] funcField ,
	 input overflowflag, 
	output  [30:0] controlWord
	
    );

	wire [4:0] addressNext; 
	wire [2:0] addressCtrl; 
	wire [4:0] seq; 
	wire [4:0] dt1;
	wire [4:0] dt2;
	wire [4:0] dt3;
	wire [4:0] wbAddr;
	//wire [28:0] controlWord;
	
	DT1 dispTbl1(opCode , funcField, dt1);
	DT2 dispTbl2(opCode , funcField, dt2);
   DT3 dispTbl3(opCode , dt3);
	WriteBack wb(opCode , funcField, wbAddr);
	adder add0(addressNext,seq);
	
	NxtAddrMux mux1(clk, reset, addressCtrl , wbAddr, dt3,  dt2, dt1,
						 seq, 5'd0 , addressNext  );
   
	controlUnit c1( addressNext,
						clk,
					overflowflag ,
						addressCtrl,
						controlWord
					
					);
      
	 
endmodule

//Dispatch table 1
module DT1(input [5:0] opCode , input [5:0] funcField, output reg[4:0] addressNext
    );
	 
	always@(*)
	begin 
		case(opCode)
		6'd0: begin
				if(funcField == 6'd16) //mfhi
					addressNext=5'd2;
					
				else if(funcField == 6'd18) //mflo
					addressNext=5'd3;
					
				else if(funcField == 6'd17) //mthi
					addressNext=5'd4;
					
				else if(funcField == 6'd19) //mtlo
 					addressNext=5'd5;
					
				else if(funcField == 6'd8)//jr
					addressNext=5'd10;
					
				else if(funcField == 6'd9) //jalr
					addressNext=5'd11;
				
				else if(funcField == 6'd32) //add
					addressNext=5'd12;
					
				else if(funcField == 6'd0) //sll
					addressNext=5'd13;
				 
				else if(funcField == 6'd4) //sllv
					addressNext=5'd14;
					
				else if(funcField == 6'd26) //div
					addressNext=5'd15;
				
				else if(funcField == 6'd24) //mult
					addressNext=5'd16;
					
				end
		6'd2: addressNext=5'd8; //j 
		6'd3: addressNext=5'd9; //jal
		6'd4: addressNext=5'd7; //beq
		6'd15:addressNext=5'd6; //lui
		6'd28:addressNext=5'd16; // madd msub
		6'd13:addressNext=5'd18; //ori
		6'd8:addressNext =5'd17; //addi
		6'd35:addressNext=5'd17; //lw
		6'd43:addressNext=5'd17; //sw
		default: begin
		addressNext=5'd27; //invalid
		
		end
	endcase

	end

endmodule

//Dispatch table 2
module DT2(input [5:0] opCode , input [5:0] funField, output reg[4:0] addressNext
    );

always@(*)

begin
	case(opCode) //WB stages of resp instructions
	6'd0: begin
				if(funField == 6'd24) //mult
					addressNext=5'd20;
				
			end
	6'd28: begin
				 if(funField == 6'd0) //madd
					addressNext=5'd21;
				
				 else if(funField == 6'd4)//msub
					addressNext=5'd22;
				 end
				 
	endcase


end 
endmodule

//Dispatch table 3
module DT3(input [5:0] opCode,output reg[4:0] addressNext
    );
	 
always@(*)
	begin
	case(opCode) //MEM / WB stages of resp instructions 
		6'd35: addressNext=5'd23; //lw
		6'd43: addressNext=5'd24; //sw
		6'd8:  addressNext=5'd25; //addi (WB)
		
	endcase
	
	end

endmodule

//Writeback
module WriteBack(input [5:0] opCode , input [5:0] funcField, output reg[4:0] addressNext
    );
	 
	always@(*)
	begin  //WB stages of resp instructions
		case(opCode)
		6'd0: begin
				if(funcField == 6'd32) //add
					addressNext=5'd19;
					
				else if(funcField == 6'd0) //sll
					addressNext=5'd19;
				 
				else if(funcField == 6'd4) //sllv
					addressNext=5'd19;
					
				else if(funcField == 6'd26) //div
					addressNext=5'd20;
				end
		6'd35: addressNext=5'd26; //lw
		6'd13: addressNext=5'd25; //ori
		
		endcase
	end
endmodule

//adder for sequence
module adder(input [4:0] address, output reg [4:0] sequenceAddr
    );
always@(address)
begin
sequenceAddr=address+1;
end

endmodule

//mux
module NxtAddrMux(input clk, input reset,input [2:0] addressCtrl , input [4:0] wbAddr, input [4:0] dt3, input [4:0] dt2, input [4:0] dt1,
						input [4:0] seq, input [4:0] fetch , output reg [4:0] nextAddress
    );
	
	always@(posedge clk)
	begin
	if(reset)
		nextAddress= fetch;
	else 
	
	
	case(addressCtrl)
	3'd0:nextAddress= fetch;
	3'd1:nextAddress= seq;
	3'd2:nextAddress= dt1;
	3'd3:nextAddress= dt2;
	3'd4:nextAddress= dt3;
	3'd5:nextAddress= wbAddr;
	endcase

	
	end
	
endmodule

//Control Unit
module controlUnit(input [4:0] addressNext,
						 input clk,
						 input overflowflag ,
						 output reg[2:0] addressControl,
						  output reg [30:0] controlWord
						   
    );
		
		reg [33:0] controlSignalsArray [27:0];  
		reg [33:0] controlComp;
		always@(negedge clk)
		  begin
												
			
	// exceptionBits2b pcWr pcWrCond pcSrc2b IorD MemRd MemWr IRWr srcA2b srcB3b aluCtrl3b hiSel2b loSel2b hiWR loWr malu memtoREg regdst regWr addrCtrl3b 
		controlSignalsArray[0] =34'b00_1_0_00_0_1_0_1_00_000_000_00_00_0_0_0_000_00_0_001; // IF
		controlSignalsArray[1] =34'b00_0_0_00_0_0_0_0_00_010_000_00_00_0_0_0_000_00_0_010; // ID
		controlSignalsArray[2] =34'b00_0_0_00_0_0_0_0_00_000_000_00_00_0_0_0_100_00_1_000; // EX mfhi
		controlSignalsArray[3] =34'b00_0_0_00_0_0_0_0_00_000_000_00_00_0_0_0_101_00_1_000; // EX mflo
		controlSignalsArray[4] =34'b00_0_0_00_0_0_0_0_00_000_000_01_00_1_0_0_000_00_0_000; // EX mthi
		controlSignalsArray[5] =34'b00_0_0_00_0_0_0_0_00_000_000_00_01_0_1_0_000_00_0_000; // EX mtlo
		controlSignalsArray[6] =34'b00_0_0_00_0_0_0_0_00_000_000_00_00_0_0_0_011_00_1_000; // EX lui
		controlSignalsArray[7] =34'b00_0_1_01_0_0_0_0_01_001_001_00_00_0_0_0_000_00_0_000; // EX beq
		controlSignalsArray[8] =34'b00_1_0_10_0_0_0_0_00_000_000_00_00_0_0_0_000_00_0_000; // EX j
		controlSignalsArray[9] =34'b00_1_0_10_0_0_0_0_00_000_000_00_00_0_0_0_010_10_1_000; // EX jal
		controlSignalsArray[10] =34'b00_1_0_11_0_0_0_0_00_000_000_00_00_0_0_0_000_00_0_000; // EX jr
		controlSignalsArray[11] =34'b00_1_0_11_0_0_0_0_00_000_000_00_00_0_0_0_010_00_1_000; // EX jalr
		controlSignalsArray[12] =34'b00_0_0_00_0_0_0_0_01_001_000_00_00_0_0_0_000_00_0_101; // EX add
		controlSignalsArray[13] =34'b00_0_0_00_0_0_0_0_10_001_100_00_00_0_0_0_000_00_0_101; // EX sll
		controlSignalsArray[14] =34'b00_0_0_00_0_0_0_0_01_001_100_00_00_0_0_0_000_00_0_101; // EX sllv
		controlSignalsArray[15] =34'b00_0_0_00_0_0_0_0_01_001_100_00_00_0_0_0_000_00_0_101; // EX div
		controlSignalsArray[16] =34'b00_0_0_00_0_0_0_0_01_001_011_00_00_0_0_0_000_00_0_011; // EX mult, madd , msub
		
		controlSignalsArray[17] =34'b00_0_0_00_0_0_0_0_01_011_000_00_00_0_0_0_000_00_0_100; // EX addi, lw, sw
		controlSignalsArray[18] =34'b00_0_0_00_0_0_0_0_01_010_101_00_00_0_0_0_000_00_0_101; // EX ori
		controlSignalsArray[19] =34'b00_0_0_00_0_0_0_0_00_000_000_00_00_0_0_0_000_00_1_000; // WB add, sll , sllv
		controlSignalsArray[20] =34'b00_0_0_00_0_0_0_0_00_000_000_00_00_1_1_0_000_00_0_000; // WB div , mult
		
      controlSignalsArray[21] =34'b00_0_0_00_1_1_0_0_00_000_000_00_00_0_0_0_000_00_0_000; // WB madd
      controlSignalsArray[22] =34'b00_0_0_00_1_1_0_0_00_000_000_00_00_0_0_0_000_00_0_000; // WB msub
      controlSignalsArray[23] =34'b00_0_0_00_1_0_1_0_00_000_000_00_00_0_0_0_000_00_0_101; // MEM lw
      controlSignalsArray[24] =34'b00_0_0_00_0_0_0_0_00_000_000_00_00_0_0_0_000_01_1_000; // MEM sw
      controlSignalsArray[25] =34'b00_0_0_00_0_0_0_0_00_000_000_00_00_0_0_0_001_01_1_000; // WB addi ori

		controlSignalsArray[26] =34'b00_0_0_00_0_0_0_0_00_000_000_00_00_0_0_0_001_01_1_000; // WB lw --> CHECK
		
		controlSignalsArray[27] =34'b11_1_1_11_1_1_1_1_11_111_111_11_11_1_1_1_111_11_1_111; // Invalid Instruction exception
		
		
		if(overflowflag)
		begin
		controlSignalsArray[19] =34'b10_0_0_00_0_0_0_0_00_000_000_00_00_0_0_0_000_00_1_000; //WB add with overflow bits set
		controlSignalsArray[25] =34'b10_0_0_00_0_0_0_0_00_000_000_00_00_0_0_0_001_01_1_000; // WB addi with overflow bits set

		end
		
		controlComp=controlSignalsArray[addressNext];
		controlWord=controlComp[33:3];
		addressControl=controlComp[2:0];
		
	
		
		end
endmodule

//TEST BENCH for Main module
module MainModuleTest;

	// Inputs
	reg clk;
	reg reset;
	reg [5:0] opCode;
	reg [5:0] funcField;
	reg overflowflag;
	// Outputs
	wire [30:0] controlWord;
		// Instantiate the Unit Under Test (UUT)
	MainModule uut (
		.clk(clk), 
		.reset(reset), 
		.opCode(opCode), 
		.funcField(funcField),
		.overflowflag(overflowflag),
		.controlWord(controlWord)
		
	);
always 
	#10 clk=~clk;
	initial begin

	
		// Initialize Inputs
		clk = 0;
		reset = 0;
		opCode = 0;
		funcField = 0;
		overflowflag=0;
		
		#10 reset=1;
		//3 stages
      #10 opCode=6'd0; funcField=6'd16;reset=0; //mfhi
		#60 opCode=6'd0; funcField=6'd18;//mflo
		#60 opCode=6'd0; funcField=6'd17;//mthi
		#60 opCode=6'd0; funcField=6'd19;//mtlo
		#60 opCode=6'd15; funcField=6'd19;//lui
		#60 opCode=6'd4; funcField=6'd19;//beq
		#60 opCode=6'd2; funcField=6'd19;//j
		#60 opCode=6'd3; funcField=6'd19;//jal
		#60 opCode=6'd0; funcField=6'd8;//jr
		#60 opCode=6'd0; funcField=6'd9;//jalr
		//4 stages
		#60 opCode=6'd0; funcField=6'd32; overflowflag=1;//add
		#80 opCode=6'd0; funcField=6'd0; overflowflag=0; //sll
		#80 opCode=6'd0; funcField=6'd4; //sllv
		#80 opCode=6'd0; funcField=6'd26; //div
		#80 opCode=6'd0; funcField=6'd24; //mult
		#80 opCode=6'd28; funcField=6'd0; //madd
		#80 opCode=6'd28; funcField=6'd4; //msub
		#80 opCode=6'd8; funcField=6'd0; overflowflag=1; //addi
		#80 opCode=6'd43; funcField=6'd0; overflowflag=0; //sw
		#80 opCode=6'd13; funcField=6'd0; //ori
		//5 stages
		#80 opCode=6'd35; funcField=6'd0; //lw
		#100 opCode=6'd44; funcField=6'd0; //invalid instruction opcode
		#60 reset=1;
   end   
endmodule


