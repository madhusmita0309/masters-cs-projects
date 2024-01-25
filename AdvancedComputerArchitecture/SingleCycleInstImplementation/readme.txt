1. Name: Madhusmita Oke
2. ID : 2018H1030194G
3. Waveform order thats specified in testbench (as well as the screenshots doc named- Waveforms.docx)
	
mfhi
mflo
mthi
mtlo
lui
beq
j
jal
jr
jalr
add
sll
sllv
div
mult
madd
msub
addi
sw
ori
lw
invalid instruction opcode

4. Some description pointers:

-The control Word size is 34bits
-The bits for identifying overflow exception : controlWord[33:32] - set to 10 in case of overflow otherwise set 00
-For OverFlow Exception input flag -overflowflag is set to 1 for indicating overflow (shown in add, addi instructions) 
-For Invalid Instruction Exception -its identified at ID stage and leads to last stage(reserved for invalid one). It happens when opcode in test bench is incorrect/ doesnt correspond to any valid instruction. 


	