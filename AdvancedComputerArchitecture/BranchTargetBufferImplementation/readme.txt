1. Name: Madhusmita Oke
2. ID : 2018H1030194G
3. Waveform present in Waveforms-Assignment3.docx
4. Few Description pointers:
-BTA buffer is written with bta value specified in testbench when btaWrite enable is set
-The Prediction buffer has actualPredict as input to branchtaken or nottaken
-According to values present in buffer and predict bit we decide to update / not update the buffer (test cases in testbench)- this is done when write predict buffer enable is set
- Corresponding bta and predict bits buffer are outputs (based on 2 bits of pc[1:0] given in test bench)
The states can be described as:(00-Predict Taken , 01 Predict Taken, 11- Predict Not Taken ,10-Predict Not Taken)
(if taken unchanged)
00 (predict taken)---(not taken)-->Predict Taken(01)
			/|\ <---(Taken)------	|
(Taken)		 |						|(Not Taken)
			 |					   \|/
11(predict nottaken)--(Nt taken)->(Predict Not Taken) (10)
					<---(Taken)-----(if not taken unchanged)
