-module(task14).
-export([start/0, send/2, proc_1/3, proc_2/3, proc_3/3, test/0]).

proc_1(TS1, TS2, TS3) ->
	receive
		{Receiver, Msg} ->
			io:format("Process 1 is sending ~p to process ~p Timestamp: [~p,~p,~p]~n", [Msg, Receiver, TS1 + 1, TS2, TS3]),

			if
			  Receiver == 2 ->
			  	proc_2 ! {Msg, TS1 + 1, TS2, TS3};
			  Receiver == 3 ->
					proc_3 ! {Msg, TS1 + 1, TS2, TS3};
			  true ->
					io:format("Wrong Receiver", [])
		 	end,

			proc_1(TS1 + 1, TS2, TS3);

		{Message, TS1_, TS2_, TS3_} ->
					io:format("Process 1 got message ~p Timestamp:[~p,~p,~p]~n", [Message, max(TS1, TS1_) + 1, max(TS2, TS2_), max(TS3, TS3_)]),
					proc_1(max(TS1, TS1_) + 1, max(TS2, TS2_), max(TS3, TS3_))
	end.


proc_2(TS1, TS2, TS3) ->
	receive
		{Receiver, Msg} ->
			io:format("Process 2 is sending ~p to process ~p Timestamp:[~p,~p,~p]~n", [Msg, Receiver, TS1, TS2 + 1, TS3]),

			if
			  Receiver == 1 ->
			  	proc_1 ! {Msg, TS1, TS2 + 1, TS3};
			  Receiver == 3 ->
					proc_3 ! {Msg, TS1, TS2 + 1, TS3};
			  true ->
					io:format("Wrong Receiver", [])
		 	end,

			proc_2(TS1, TS2 + 1, TS3);

		{Message, TS1_, TS2_, TS3_} ->
					io:format("Process 2 got message ~p Timestamp:[~p,~p,~p]~n", [Message, max(TS1, TS1_), max(TS2, TS2_) + 1, max(TS3, TS3_)]),
					proc_2(max(TS1, TS1_), max(TS2, TS2_) + 1, max(TS3, TS3_))
	end.


proc_3(TS1, TS2, TS3) ->
	receive
		{Receiver, Msg} ->
			io:format("Process 3 is sending ~p to process ~p Timestamp:[~p,~p,~p]~n", [Msg, Receiver, TS1, TS2, TS3 + 1]),

			if
			  Receiver == 1 ->
			  	proc_1 ! {Msg, TS1, TS2, TS3 + 1};
			  Receiver == 2 ->
					proc_2 ! {Msg, TS1, TS2, TS3 + 1};
			  true ->
					io:format("Wrong Receiver", [])
		 	end,

			proc_3(TS1, TS2, TS3 + 1);

		{Message, TS1_, TS2_, TS3_} ->
					io:format("Process 3 got message ~p Timestamp:[~p,~p,~p]~n", [Message, max(TS1, TS1_), max(TS2, TS2_), max(TS3, TS3_) + 1]),
					proc_3(max(TS1, TS1_), max(TS2, TS2_), max(TS3, TS3_) + 1)
	end.



send(SenderReceiver, Msg) ->
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


start() ->
  register(proc_1, spawn(task14, proc_1, [0, 0, 0])),
	register(proc_2, spawn(task14, proc_2, [0, 0, 0])),
	register(proc_3, spawn(task14, proc_3, [0, 0, 0])).


test() ->
	send(12, "hello"),
	send(23, "Hi!"),
	send(31, "Bonjour"),
	send(13, "Privet!").
