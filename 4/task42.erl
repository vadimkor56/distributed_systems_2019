-module(task42).
-export([start/0, coordinator/4, proc/4]).

coordinator(TxnToCommit, ProcList, Num, Flag) ->
	if
		Flag == 3 ->
			[Proc ! state_req || Proc <- ProcList];
		true ->
			timer:sleep(1)
	end,

	if
		Num == length(ProcList) ->
			if
				Flag == 0 ->
					[Proc ! {prepare_commit, TxnToCommit} || Proc <- ProcList],
					coordinator(TxnToCommit, ProcList, 0, 2);
				Flag == 2 ->
					[Proc ! {commit, TxnToCommit} || Proc <- ProcList];
				Flag == 4 ->
					[Proc ! {rollback, TxnToCommit} || Proc <- ProcList]
			end;
		true ->
			timer:sleep(1)
	end,

	if
		Flag == 1 ->
			io:format("Coordinator asks participants about txn ~p~n", [TxnToCommit]),
			[ Proc ! {txn, TxnToCommit} || Proc <- ProcList ],
			timer:sleep(500),
			[ Proc ! {proc_list, ProcList} || Proc <- ProcList ];
		true ->
			timer:sleep(1)
	end,
	receive
		{ans, Ans} ->
			if
				Ans == 0 ->
					[Proc ! {rollback, TxnToCommit} || Proc <- ProcList],
					coordinator(TxnToCommit, ProcList, 0, 0);
				true ->
					coordinator(TxnToCommit, ProcList, Num + 1, 0)
			end;
		{state, State} ->
			if
				State == "Commited" ->
					[Proc ! {commit, TxnToCommit} || Proc <- ProcList];
				State == "RolledBack" ->
					[Proc ! {abort, TxnToCommit} || Proc <- ProcList];
				State == "Uncertain" ->
					coordinator(TxnToCommit, ProcList, Num + 1, 4)
			end;
		{ack, Proc} ->
			io:format("Coordinator received the acknowledgement from ~p~n", [Proc]),
			coordinator(TxnToCommit, ProcList, Num + 1, 2)
	after 1000 ->
		[Proc ! {rollback, TxnToCommit} || Proc <- ProcList],
		coordinator(TxnToCommit, ProcList, 0, 0)
	end.



proc(IsOk, Coordinator, State, ProcList) ->
	receive
		{proc_list, ProcList_} ->
			proc(IsOk, Coordinator, State, ProcList_);
		{txn, TxnToCommit} ->
			io:format("Proc ~p is trying to do txn ~p~n", [self(), TxnToCommit]),
			if
				IsOk ->
					io:format("Proc ~p is sending Yes to the coordinator ~n", [self()]),
					if
						Coordinator == 0 ->
							coord ! {ans, 1};
						true ->
							Coordinator ! {ans, 1}
					end;
				true ->
					io:format("Proc ~p is sending No to the coordinator ~n", [self()]),
					if
						Coordinator == 0 ->
							coord ! {ans, 0};
						true ->
							Coordinator ! {ans, 0}
					end
			end,
			proc(IsOk, Coordinator, State, ProcList);
		{rollback, Txn} ->
			io:format("Proc ~p is aborting txn~p~n", [self(), Txn]);
		{newCoord, NewCoord} ->
			io:format("~p is the new coordinator~n", [NewCoord]),
			proc(IsOk, NewCoord, State, ProcList);
		state_req ->
			if
				Coordinator == 0 ->
					coord ! {state, State};
				true ->
					Coordinator ! {state, State}
			end;
		{prepare_commit, Txn} ->
			io:format("Proc ~p received prepare-commit for txn ~p from coordinator~n", [self(), Txn]),
			if
				Coordinator == 0 ->
					coord ! {ack, self()};
				true ->
					Coordinator ! {ack, self()}
			end,
			proc(IsOk, Coordinator, "Uncertain", ProcList);
		{commit, Txn} ->
			io:format("Proc ~p is commiting txn~p~n", [self(), Txn]),
			proc(IsOk, Coordinator, "Commited", ProcList);
		fail ->
			timer:sleep(1)
	after 1200 ->
		election(ProcList)
	end.


election(ProcList) ->
	NewProcList = lists:droplast(ProcList),
	NewCoord = spawn(task42, coordinator, ["txn1", NewProcList, 0, 3]),
	[Proc ! {newCoord, NewCoord} || Proc <- NewProcList].


start() ->
	Proc_1 = spawn(task42, proc, [true, 0, "", ""]),
	Proc_2 = spawn(task42, proc, [true, 0, "", ""]),
	Proc_3 = spawn(task42, proc, [true, 0, "", ""]),
	ProcList = [Proc_1, Proc_2, Proc_3],
	register(coord, spawn(task42, coordinator, ["txn1", ProcList, 0, 1])).
