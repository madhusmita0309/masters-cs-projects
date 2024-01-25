`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:45:46 03/26/2019 
// Design Name: 
// Module Name:    Assignment3final 
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
module MainModule(input clk, input reset, input [31:0] pc,input [31:0] bta,input btaWrite, input actualPredict, input writePredBuffEn,output wire[31:0] btaBuffOp,output wire[1:0] predBuffOp//main pred
    );
wire[1:0] pcBits;
wire[3:0] decOut1;

wire[31:0] outR0;
wire[31:0] outR1;
wire[31:0] outR2;
wire[31:0] outR3;


PCSep psep(pc,pcBits);
decoder2to4 d1(pcBits,decOut1);
BTABuffer b1(clk,reset,btaWrite,decOut1,bta,outR0,outR1,outR2,outR3);
Mux4to1 m1(outR3,outR2, outR1,outR0,pcBits,btaBuffOp);


PredictionBuffer pb1(actualPredict
							,writePredBuffEn 
							,pcBits 
							,clk
							,reset
							,predBuffOp);

 
endmodule

// Module to separate 2 bits of PC

module PCSep(input [31:0] pc, output reg [1:0] pcBits
    );
always @(*)
begin
pcBits=pc[1:0];
end

endmodule

// decoder 

module decoder2to4( input [1:0] pcBits, output reg [3:0] decOut
    );

always @ (*)
begin
case(pcBits)
2'd0:decOut=4'b0001;
2'd1:decOut=4'b0010;
2'd2:decOut=4'b0100;
2'd3:decOut=4'b1000;
endcase
end

endmodule

// BTA buffer
module BTABuffer(input clk, input reset, input regWrite, input [3:0] decOut, input [31:0] writeData,output [31:0] outR0,output [31:0] outR1,output [31:0] outR2,output [31:0] outR3
    );
register32bit r0(clk, reset, regWrite, decOut[0],writeData , outR0);
register32bit r1(clk, reset, regWrite, decOut[1], writeData, outR1);
register32bit r2(clk, reset, regWrite, decOut[2], writeData, outR2);
register32bit r3(clk, reset, regWrite, decOut[3], writeData, outR3);
endmodule

//32 bit register module
module register32bit(input clk,input reset, input regWrite,input decOut,input [31:0] writeData,output [31:0] outBus);
	d_ff d0(clk,reset,regWrite,writeData[0],decOut,outBus[0]);
	d_ff d1(clk,reset,regWrite,writeData[1],decOut,outBus[1]);
	d_ff d2(clk,reset,regWrite,writeData[2],decOut,outBus[2]);
	d_ff d3(clk,reset,regWrite,writeData[3],decOut,outBus[3]);
	d_ff d4(clk,reset,regWrite,writeData[4],decOut,outBus[4]);
	d_ff d5(clk,reset,regWrite,writeData[5],decOut,outBus[5]);
	d_ff d6(clk,reset,regWrite,writeData[6],decOut,outBus[6]);
	d_ff d7(clk,reset,regWrite,writeData[7],decOut,outBus[7]);
	d_ff d8(clk,reset,regWrite,writeData[8],decOut,outBus[8]);
	d_ff d9(clk,reset,regWrite,writeData[9],decOut,outBus[9]);
	d_ff d10(clk,reset,regWrite,writeData[10],decOut,outBus[10]);
	d_ff d11(clk,reset,regWrite,writeData[11],decOut,outBus[11]);
	d_ff d12(clk,reset,regWrite,writeData[12],decOut,outBus[12]);
	d_ff d13(clk,reset,regWrite,writeData[13],decOut,outBus[13]);
	d_ff d14(clk,reset,regWrite,writeData[14],decOut,outBus[14]);
	d_ff d15(clk,reset,regWrite,writeData[15],decOut,outBus[15]);
	d_ff d16(clk,reset,regWrite,writeData[16],decOut,outBus[16]);
	d_ff d17(clk,reset,regWrite,writeData[17],decOut,outBus[17]);
	d_ff d18(clk,reset,regWrite,writeData[18],decOut,outBus[18]);
	d_ff d19(clk,reset,regWrite,writeData[19],decOut,outBus[19]);
	d_ff d20(clk,reset,regWrite,writeData[20],decOut,outBus[20]);
	d_ff d21(clk,reset,regWrite,writeData[21],decOut,outBus[21]);
	d_ff d22(clk,reset,regWrite,writeData[22],decOut,outBus[22]);
	d_ff d23(clk,reset,regWrite,writeData[23],decOut,outBus[23]);
	d_ff d24(clk,reset,regWrite,writeData[24],decOut,outBus[24]);
	d_ff d25(clk,reset,regWrite,writeData[25],decOut,outBus[25]);
	d_ff d26(clk,reset,regWrite,writeData[26],decOut,outBus[26]);
	d_ff d27(clk,reset,regWrite,writeData[27],decOut,outBus[27]);
	d_ff d28(clk,reset,regWrite,writeData[28],decOut,outBus[28]);
	d_ff d29(clk,reset,regWrite,writeData[29],decOut,outBus[29]);
	d_ff d30(clk,reset,regWrite,writeData[30],decOut,outBus[30]);
	d_ff d31(clk,reset,regWrite,writeData[31],decOut,outBus[31]);
endmodule

//d flipflop
module d_ff(input clk ,input reset, input regWrite, input d, input decOut, output reg q);
	always @(negedge clk)
	begin
	if(reset==1)
		q=0;
	else
	if(regWrite == 1 && decOut==1)
		begin
		q=d;
		end
	end
endmodule

//Mux 
module Mux4to1(input [31:0] op3,input [31:0] op2, input [31:0] op1, input [31:0] op0, input [1:0] sel,output reg [31:0] out0
    );
always@(*)
		begin
			case(sel)
			
			2'd0:out0=op0;
			2'd1:out0=op1;
			2'd2:out0=op2;
			2'd3:out0=op3;
			endcase
		
		end



endmodule

// Prediction Bufffer module

module PredictionBuffer(input  actualPred 
							,input  writeEn 
							,input [1:0] pcBits 
							,input clk
							,input reset
							,output reg [1:0] mainPredict
    );
 reg [1:0] predBuff [3:0];  
 initial begin
	 

			if(reset)
			begin
			predBuff[0]=2'd0;
			predBuff[1]=2'd0;
			predBuff[2]=2'd0;
			predBuff[3]=2'd0;
			mainPredict=2'd0;
			end
			

end

always@(posedge clk)
begin
case(predBuff[pcBits])
2'd0:begin //00 in buffer
		if(!actualPred)
			mainPredict=2'd1;//if not branch taken
		else
			mainPredict=predBuff[pcBits];
		end
2'd1:begin  //01 in buffer
	if(actualPred)
		mainPredict=2'd0; //if branch taken
	else
		mainPredict=2'd2; //if branch not taken
		end 
2'd2: begin //10 in buffer
		if(actualPred)
			mainPredict=2'd3; //if branch taken
		else
			mainPredict=predBuff[pcBits];

		end
2'd3:begin //11 in buffer
		if(actualPred) 
		mainPredict=2'd0; //branch taken
		else
		mainPredict=2'd2; //branch not taken
		end
		endcase

end

always@(negedge clk)
begin
if(reset)
	mainPredict=2'd0;
if(writeEn)
begin
predBuff[pcBits]=mainPredict;
end

end


endmodule

//Test Bench for Main Module

module MainTest;

	// Inputs
	reg clk;
	reg reset;
	reg [31:0] pc;
	reg [31:0] bta;
	reg btaWrite;
	reg actualPredict;
	reg writePredBuffEn;

	// Outputs
	wire [31:0] btaBuffOp;
	wire [1:0] predBuffOp;

	// Instantiate the Unit Under Test (UUT)
	MainModule uut (
		.clk(clk), 
		.reset(reset), 
		.pc(pc), 
		.bta(bta), 
		.btaWrite(btaWrite), 
		.actualPredict(actualPredict), 
		.writePredBuffEn(writePredBuffEn), 
		.btaBuffOp(btaBuffOp), 
		.predBuffOp(predBuffOp)
	);
	always
	#10 clk=~clk;
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		pc = 0;
		bta = 0;
		btaWrite = 0;
		actualPredict = 0;
		writePredBuffEn = 0;

		
		#10 reset=1;writePredBuffEn=1;
		//BTA buffer is populated with given bta
		#20 reset=0; pc=32'b1111_1111_1111_1111_0000_0000_0000_0000 ; actualPredict=1; btaWrite=1;bta=32'd5;writePredBuffEn=1;

		#20 pc=32'b1111_1111_1111_1111_0000_0000_0000_0001; actualPredict=1;btaWrite=1;bta=32'd7;writePredBuffEn=1;

		#20 pc=32'b1111_1111_1111_1111_0000_0000_0000_0010; actualPredict=1;btaWrite=1;bta=32'd9;writePredBuffEn=1;

		#20 pc=32'b1111_1111_1111_1111_0000_0000_0000_0011; actualPredict=1;btaWrite=1;bta=32'd11;writePredBuffEn=1;
       
		#20 pc=32'b1111_1111_1111_1111_0000_0000_0000_0011; actualPredict=0;writePredBuffEn=1;
		#20 pc=32'b1111_1111_1111_1111_0000_0000_0000_0011; actualPredict=0;writePredBuffEn=1;
		#20 pc=32'b1111_1111_1111_1111_0000_0000_0000_0011; actualPredict=1;writePredBuffEn=1;
		#20 pc=32'b1111_1111_1111_1111_0000_0000_0000_0011; actualPredict=1;writePredBuffEn=1;
		#20 pc=32'b1111_1111_1111_1111_0000_0000_0000_0011; actualPredict=1;writePredBuffEn=1;
		#20 pc=32'b1111_1111_1111_1111_0000_0000_0000_0011; actualPredict=0;writePredBuffEn=1;
		#20 pc=32'b1111_1111_1111_1111_0000_0000_0000_0011; actualPredict=1;writePredBuffEn=1;
	end
      
endmodule

