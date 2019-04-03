-module(task12).-export([start/0, execute/2, proc_a/2, proc_b/2]).

proc_a(ID, ExecutingAction) ->
	receive
		{Action, SenderID} ->  %% SenderID: 0 - user, 1,2,...,n - another process
			if
				Action == ExecutingAction ->
					if
						SenderID > ID ->
							proc_b ! "I am the coordinator"
					end,
					proc_a(ID, Action);
			  SenderID < ID ->
					io:format("Process A is executing ~p~n", [Action]),
			  	proc_b ! {Action, ID},
					proc_a(ID, Action);
					%%io:format("Process A finished executing ~p~n", [Action]);
			  true ->
					io:format("Process A is NOT executing ~p because his ID is smaller~n", [Action]),
					proc_b ! {ExecutingAction, ID},
					proc_a(ID, ExecutingAction)
			end;
		Msg ->
			io:format("Process A received message from B: ~p~n", [Msg]),
			proc_a(ID, ExecutingAction)
		end.

proc_b(ID, ExecutingAction) ->
	receive
		{Action, SenderID} ->
			if
				Action == ExecutingAction ->
					if
						SenderID > ID ->
							proc_a ! "I am the coordinator"
					end,
					proc_b(ID, Action);
			  SenderID < ID ->
					io:format("Process B is executing ~p~n", [Action]),
			  	proc_a ! {Action, ID},
					proc_b(ID, Action);
					%%io:format("Process B finished executing ~p~n", [Action]);
			  true ->
					io:format("Process B is NOT executing ~p because his ID is smaller~n", [Action]),
					proc_a ! {ExecutingAction, ID},
					proc_b(ID, ExecutingAction)
			end;
		Msg ->
			io:format("Process B received message from A: ~p~n", [Msg]),
			proc_b(ID, ExecutingAction)
		end.


execute(Action, Proc) ->
	if
	  Proc == 1 ->
			proc_a ! {Action, 0};
	  Proc == 2 ->
			proc_b ! {Action, 0}
	end.

start() ->
	register(proc_a, spawn(task12, proc_a, [1, "start_action1"])),
	register(proc_b, spawn(task12, proc_b, [2, "start_action2"])).
