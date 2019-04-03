-module(task34).
-export([start/0, coordinator/4, proc/3]).

coordinator(TxnToCommit, ProcList, NumOfYes, Cnt) ->
	if
		NumOfYes == length(ProcList) ->
			[Proc ! {commit, TxnToCommit} || Proc <- ProcList];
		true ->
			timer:sleep(1)
	end,

	if
		Cnt == 1 ->
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
		{abort, Proc} ->
			io:format("Proc ~p has aborted txn ~p~n", [Proc, TxnToCommit]),
			coordinator(TxnToCommit, ProcList, NumOfYes, 0);
		{commit, Proc} ->
			io:format("Proc ~p has commited txn ~p~n", [Proc, TxnToCommit]),
			coordinator(TxnToCommit, ProcList, NumOfYes, 0);
		{cancel, Proc} ->
			io:format("Proc ~p has cancelled his answer Yes (waited too long)~n", [Proc]),
			[Proc ! {rollback, TxnToCommit} || Proc <- ProcList],
			coordinator(TxnToCommit, ProcList, 0, 0)
	end.



proc(ID, IsOk, Ans) ->
	receive
		{txn, TxnToCommit} ->
			io:format("Proc ~p is trying to do txn ~p~n", [self(), TxnToCommit]),
			if
				IsOk ->
					timer:sleep(ID * 600), % just to show the cancelling possibility
					io:format("Proc ~p is sending Yes to the coordinator ~n", [self()]),
					coord ! {ans, 1},
					proc(ID, IsOk, 1);
				true ->
					io:format("Proc ~p is sending No to the coordinator ~n", [self()]),
					coord ! {ans, 0},
					proc(ID, IsOk, 0)
			end;
		{rollback, Txn} ->
			% io:format("Here", []),
			io:format("Proc ~p is aborting txn~p~n", [self(), Txn]),
			coord ! {abort, self()};
		{commit, Txn} ->
			% io:format("Here", []),
			io:format("Proc ~p is commiting txn~p~n", [self(), Txn]),
			coord ! {commit, self()}
	after
		900 ->
			if
				Ans == 1 ->
					coord ! {cancel, self()};
				true ->
					timer:sleep(1)
			end,
			proc(ID, IsOk, 0)
	end.





start() ->
	Proc_1 = spawn(task34, proc, [0, true, -1]),
	Proc_2 = spawn(task34, proc, [1, true, -1]),
	Proc_3 = spawn(task34, proc, [2, true, -1]),
	ProcList = [Proc_1, Proc_2, Proc_3],
	register(coord, spawn(task34, coordinator, ["txn1", ProcList, 0, 1])).
