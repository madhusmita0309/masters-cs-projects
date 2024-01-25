
--!TRACE

start_section :
		i    : integer :=0;
		j	 : integer :=0;
		k    : integer :=0;
		sum  : integer :=0;
		sumCap : integer :=0;
		
		lowlim : array(tasks_range) of integer;
		hilim  : array(tasks_range) of integer;
        gen1 : random;
        lot_ticket : integer;
        flag : integer :=0;
 		lottery_tick_list : array (tasks_range) of integer;
        uniform(gen1,1,100);
        to_run : integer;

end section;		

priority_section :
		sumCap := 0;
		for i in tasks_range loop
       		sumCap := sumCap + tasks.rest_of_capacity(i);
       	end loop;


       	for j in tasks_range loop
       		
       		lottery_tick_list(j):= 100-((tasks.rest_of_capacity(j)*100)/sumCap );
       		if(lottery_tick_list(j) = 100)
       			then lottery_tick_list(j) :=0;
       		end if;
       	end loop;

       	

       	j:=0; sum :=0;
		for j in tasks_range loop
			if(lottery_tick_list(j) > 0) then
			lowlim(j) :=sum+1;	
			sum := sum + lottery_tick_list(j);
			hilim(j) := sum;
			else
				lowlim(j) := 0;
				hilim(j) :=0;
			end if;
		end loop;

		uniform(gen1,1,sum);
		lot_ticket:=1;
		put(sum);
 		while (not (gen1 = lot_ticket)) and (lot_ticket <= sum) loop
 				lot_ticket := lot_ticket+1;
 		end loop; 
 		
 		put(lottery_tick_list);
 		put(lowlim);
 		put(hilim);
      	put(lot_ticket);
       	flag :=0;

       	k:=0;
       	to_run :=0;
       	for k in tasks_range loop
 			if tasks.ready(k) = true then
 			
       		if flag = 0 then
       		
       		if ( (hilim(k) > lot_ticket) or (hilim(k) = lot_ticket))
       			then
       			
       		if  ((lowlim(k) < lot_ticket) or (lowlim(k) = lot_ticket))
       			then 
       					
       				flag :=1;
       				to_run :=k;

       		end if;
       		end if;
       		end if;
       		end if;
       	end loop;
       	
       	put(to_run);
 

end section;		

election_section :
        return to_run;
end section;		



