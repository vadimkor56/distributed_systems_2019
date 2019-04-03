-module(task51).
-export([start/0, proc2/0, proc1/2]).

proc1(Timeout, AnotherProc) ->
	io:format("Sending message...~n"),
	AnotherProc ! {msg, self(), Timeout},
	io:format("Message is sent, waiting for the answer~n"),
	receive
		answer ->
			io:format("Got the answer~n")
	after Timeout ->
		io:format("Didn't get the answer within the timeout~n")
	end.

proc2() ->
	receive
		{msg, Proc, Timeout} ->
			timer:sleep(rand:uniform(2 * Timeout)),
			Proc ! answer
	end.

start() ->
	Proc_1 = spawn(task51, proc2, []),
	Proc_2 = spawn(task51, proc1, [2000, Proc_1]).
