-module(task41).
-export([start/0, coordinator/4, proc/1]).

coordinator(TxnToCommit, ProcList, NumOfYes, Flag) ->
	if
		NumOfYes == length(ProcList) ->
			if
				Flag == 0 ->
					[Proc ! {prepare_commit, TxnToCommit} || Proc <- ProcList],
					coordinator(TxnToCommit, ProcList, 0, 2);
				Flag == 2 ->
					[Proc ! {commit, TxnToCommit} || Proc <- ProcList]
			end;
		true ->
			timer:sleep(1)
	end,

	if
		Flag == 1 ->
			io:format("Coordinator asks participants about txn ~p~n", [TxnToCommit]),
			[ Proc ! {txn, TxnToCommit} || Proc <- ProcList ];
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
					coordinator(TxnToCommit, ProcList, NumOfYes + 1, 0)
			end;
		{ack, Proc} ->
			io:format("Coordinator received the acknowledgement from ~p~n", [Proc]),
			coordinator(TxnToCommit, ProcList, NumOfYes + 1, 2)
	end.



proc(IsOk) ->
	receive
		{txn, TxnToCommit} ->
			io:format("Proc ~p is trying to do txn ~p~n", [self(), TxnToCommit]),
			if
				IsOk ->
					io:format("Proc ~p is sending Yes to the coordinator ~n", [self()]),
					coord ! {ans, 1};
				true ->
					io:format("Proc ~p is sending No to the coordinator ~n", [self()]),
					coord ! {ans, 0}
			end,
			proc(IsOk);
		{rollback, Txn} ->
			io:format("Proc ~p is aborting txn~p~n", [self(), Txn]);
		{prepare_commit, Txn} ->
			io:format("Proc ~p received prepare-commit for txn ~p from coordinator~n", [self(), Txn]),
			coord ! {ack, self()},
			proc(IsOk);
		{commit, Txn} ->
			io:format("Proc ~p is commiting txn~p~n", [self(), Txn]);
		fail ->
			timer:sleep(1)
	end.





start() ->
	Proc_1 = spawn(task41, proc, [true]),
	Proc_2 = spawn(task41, proc, [true]),
	Proc_3 = spawn(task41, proc, [true]),
	ProcList = [Proc_1, Proc_2, Proc_3],
	register(coord, spawn(task41, coordinator, ["txn1", ProcList, 0, 1])).
