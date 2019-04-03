-module(task43).
-export([start/0, resource_manager/3, proc/2]).

proc(TS, ResManager) ->
	Action = rand:uniform(1),
	if
		Action == 0 ->
			ResManager ! {read, TS, self()};
		Action == 1 ->
			ResManager ! {write, TS, self()}
	end,

	receive
		no_read ->
			io:format("Process ~p didn't receive data item to read~n", [self()]),
			timer:sleep(500),
			proc(TS, ResManager);
		{can_read, DataItem} ->
			io:format("Process ~p has read data item: ~p~n", [self(), DataItem]),
			timer:sleep(500),
			proc(TS, ResManager);
		no_write ->
			io:format("Process ~p didn't receive data item to write~n", [self()]),
			timer:sleep(700),
			proc(TS, ResManager);
		{can_write, DataItem} ->
			io:format("Process ~p has wrote to the data item: ~p~n", [self(), DataItem]),
			timer:sleep(500),
			proc(TS, ResManager);
		stop ->
			timer:sleep(1)
	end.

findElem([Head | Rest], What, Cnt) ->
	if
		What >= Head ->
			findElem(Rest, What, Cnt + 1);
		true ->
			Cnt - 1
	end.


resource_manager(WTS, RTS, DataItem) ->
	receive
		{read, ProcTS, PID} ->
			LastRTS = lists:last(RTS),
			if
				ProcTS < LastRTS ->
					NumOfListElem = findElem(RTS, ProcTS, 1),
					if
						NumOfListElem == 0 ->
							io:format("Process ~p can't read because his TS is less then data item RTS~n", [PID]),
							PID ! no_read;
						true ->
							PID ! {can_read, lists:nth(NumOfListElem, DataItem)}
					end,
					resource_manager(WTS, RTS, DataItem);
				true ->
					PID ! {can_read, lists:last(DataItem)},
					resource_manager(WTS, lists:append(RTS, [ProcTS]), lists:append(DataItem, [lists:last(DataItem)]))
			end;

		{write, ProcTS, PID} ->
			LastWTS = lists:last(WTS),
			if
				ProcTS < LastWTS ->
					NumOfListElem = findElem(WTS, ProcTS, 1),
					if
						NumOfListElem == 0 ->
							io:format("Process ~p can't write because his TS is less then data item WTS~n", [PID]),
							PID ! no_write;
						true ->
							PID ! {can_write, lists:nth(NumOfListElem, DataItem)}
					end,
					resource_manager(WTS, RTS, DataItem);
				true ->
					PID ! {can_write, lists:last(DataItem)},
					NewItem = lists:last(DataItem) ++ "change",
					resource_manager(lists:append(WTS, [ProcTS]), RTS, lists:append(DataItem, [NewItem]))
			end;

		stop ->
			timer:sleep(1)
	end.


start() ->
	ResManager = spawn(task43, resource_manager, [[0, 1], [0, 1], ["Item", "Item1"]]),
	Proc_1 = spawn(task43, proc, [0, ResManager]),
	Proc_2 = spawn(task43, proc, [1, ResManager]),
	Proc_3 = spawn(task43, proc, [2, ResManager]),
	timer:sleep(3000),
	Proc_1 ! stop,
	Proc_2 ! stop,
	Proc_3 ! stop,
	ResManager ! stop.
