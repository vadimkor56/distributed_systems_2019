-module(task13a).-export([start/0, execute/2, proc_1/0, proc_2/0, proc_3/0]).

local_time(Counter) ->
	{Counter, calendar:local_time()}.

calc_receive_TS(Receive_TS, Counter) ->
	max(Receive_TS, Counter) + 1.

event(Pid, Counter) ->
	io:format('Event happend at: ~p~n', [local_time()]),
	Counter + 1.

send_message(Pid, Counter) ->
	io:format('Process ~p sent a message at: ~p~n', [Pid, local_time()]),
	