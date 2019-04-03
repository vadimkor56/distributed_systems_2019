-module(task13).-export([start/0, execute/2, proc_1/0, proc_2/0, proc_3/0]).

proc_1() ->	receive
		{Receiver, Msg} ->
			io:format("Process 1 is sending ~p to process ~p TS:~p~n", [Msg, Receiver, timestamp()]),
			
			if 
			  Receiver == 2 ->
			  	proc_2 ! Msg;
			  Receiver == 3 ->
				proc_3 ! Msg;
			  true ->
				io:format("Wrong Receiver", [])
		 	end;

		Message ->
			io:format("Process 1 got message ~p TS:~p~n", [Message, timestamp()])		end,
	proc_1().
proc_2() ->	receive
		{Receiver, Msg} ->
			io:format("Process 2 is sending ~p to process ~p TS:~p~n", [Msg, Receiver, timestamp()]),
			
			if 
			  Receiver == 1 ->
			  	proc_1 ! Msg;
			  Receiver == 3 ->
				proc_3 ! Msg;
			  true ->
				io:format("Wrong Receiver", [])
		 	end;

		Message ->
			io:format("Process 2 got message ~p TS:~p~n", [Message, timestamp()])		end,
	proc_2().


proc_3() ->	receive
		{Receiver, Msg} ->
			io:format("Process 3 is sending ~p to process ~p TS:~p~n", [Msg, Receiver, timestamp()]),
			
			if 
			  Receiver == 1 ->
			  	proc_1 ! Msg;
			  Receiver == 2 ->
				proc_2 ! Msg;
			  true ->
				io:format("Wrong Receiver", [])
		 	end;

		Message ->
			io:format("Process 3 got message ~p TS:~p~n", [Message, timestamp()])		end,
	proc_3().	

		
timestamp() ->
    {MegaSecs, Secs, MicroSecs} = os:timestamp(),
    MegaSecs*1000000000000 + Secs*1000000 + MicroSecs.


execute(SenderReceiver, Msg) ->
	Sender = trunc(SenderReceiver / 10), 
	Receiver = SenderReceiver rem 10,
	if 
	  Sender == 1 ->
		proc_1 ! {Receiver, Msg};
	  Sender == 2 ->		  
		proc_2 ! {Receiver, Msg};
	  Sender == 3 ->
		proc_3 ! {Receiver, Msg};
	  true ->
		io:format("Wrong Sender", [])
	end.

start() ->	register(proc_1, spawn(task13, proc_1, [])),
	register(proc_2, spawn(task13, proc_2, [])),
	register(proc_3, spawn(task13, proc_3, [])).
