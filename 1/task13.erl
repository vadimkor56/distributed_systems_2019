-module(task13b).
-export([start/0, execute/2, proc_1/1, proc_2/1, proc_3/1, test/0]).

proc_1(TS1) ->
	receive
		{Receiver, Msg} ->
			io:format("Process 1 is sending ~p to process ~p Timestamp:~p~n", [Msg, Receiver, TS1 + 1]),

			if
			  Receiver == 2 ->
			  	proc_2 ! {Msg, TS1 + 1, 0};
			  Receiver == 3 ->
					proc_3 ! {Msg, TS1 + 1, 0};
			  true ->
					io:format("Wrong Receiver", [])
		 	end,

			proc_1(TS1 + 1);

		{Message, TS, Nothing} ->
			if
			  TS > TS1 ->
					io:format("Process 1 got message ~p Timestamp:~p~n", [Message, TS + 1]),
					proc_1(TS + 1);
			  true ->
					io:format("Process 1 got message ~p Timestamp:~p~n", [Message, TS1 + 1]),
					proc_1(TS1 + 1)
			end
	end.

proc_2(TS2) ->
	receive
		{Receiver, Msg} ->
			io:format("Process 2 is sending ~p to process ~p Timestamp:~p~n", [Msg, Receiver, TS2 + 1]),

			if
			  Receiver == 1 ->
			  	proc_1 ! {Msg, TS2 + 1, 0};
			  Receiver == 3 ->
					proc_3 ! {Msg, TS2 + 1, 0};
			  true ->
					io:format("Wrong Receiver", [])
		 	end,

			proc_2(TS2 + 1);

		{Message, TS, Nothing} ->
			if
			  TS > TS2 ->
					io:format("Process 2 got message ~p Timestamp:~p~n", [Message, TS + 1]),
					proc_2(TS + 1);
			  true ->
					io:format("Process 2 got message ~p Timestamp:~p~n", [Message, TS2 + 1]),
					proc_2(TS2 + 1)
			end
	end.


proc_3(TS3) ->
	receive
		{Receiver, Msg} ->
			io:format("Process 3 is sending ~p to process ~p Timestamp:~p~n", [Msg, Receiver, TS3 + 1]),

			if
			  Receiver == 2 ->
			  	proc_2 ! {Msg, TS3 + 1, 0};
			  Receiver == 1 ->
					proc_1 ! {Msg, TS3 + 1, 0};
			  true ->
					io:format("Wrong Receiver", [])
		 	end,

			proc_3(TS3 + 1);

		{Message, TS, Nothing} ->
			if
			  TS > TS3 ->
					io:format("Process 3 got message ~p Timestamp:~p~n", [Message, TS + 1]),
					proc_3(TS + 1);
			  true ->
					io:format("Process 3 got message ~p Timestamp:~p~n", [Message, TS3 + 1]),
					proc_3(TS3 + 1)
			end
	end.



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

start() ->
  register(proc_1, spawn(task13b, proc_1, [0])),
	register(proc_2, spawn(task13b, proc_2, [0])),
	register(proc_3, spawn(task13b, proc_3, [0])).


test() ->
	execute(12, "hello"),
	execute(23, "Hi!"),
	execute(31, "Bonjour"),
	execute(13, "Privet!").
