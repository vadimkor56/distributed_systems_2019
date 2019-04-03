-module(task32).
-export([start/0, coordinator/5, proc/1]).

coordinator(TxnToCommit, ProcList, NumOfYes, Cnt, Timeout) ->
	if
		NumOfYes == length(ProcList) ->
			[Proc ! {commit, TxnToCommit} || Proc <- ProcList];
		true ->
			timer:sleep(1)
	end,

	if
		Cnt == 1 ->
			[ Proc ! {vote_req, TxnToCommit} || Proc <- ProcList ];
		true ->
			timer:sleep(1)
	end,
	receive
		{ans, Ans} ->
			if
				Ans == 0 ->
					[Proc ! {rollback, TxnToCommit} || Proc <- ProcList],
					coordinator(TxnToCommit, ProcList, 0, 0, Timeout);
				true ->
					coordinator(TxnToCommit, ProcList, NumOfYes + 1, 0, Timeout)
			end;
		{abort, Proc} ->
			io:format("Proc ~p has aborted txn ~p~n", [Proc, TxnToCommit]),
			coordinator(TxnToCommit, ProcList, NumOfYes, 0, Timeout);
		{commit, Proc} ->
			io:format("Proc ~p has commited txn ~p~n", [Proc, TxnToCommit]),
			coordinator(TxnToCommit, ProcList, NumOfYes, 0, Timeout)
	after Timeout ->
		io:format("Coordinator timed out. Sending rollbacks...~n"),
		[Proc ! {rollback, TxnToCommit} || Proc <- ProcList]
	end.



proc(IsOk) ->
	receive
		{vote_req, TxnToCommit} ->
			io:format("Proc ~p is trying to do txn ~p~n", [self(), TxnToCommit]),
			timer:sleep(rand:uniform(2000)),
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
			% io:format("Here", []),
			io:format("Proc ~p is aborting txn~p~n", [self(), Txn]),
			coord ! {abort, self()};
		{commit, Txn} ->
			% io:format("Here", []),
			io:format("Proc ~p is commiting txn~p~n", [self(), Txn]),
			coord ! {commit, self()}
	end.





start() ->
	Proc_1 = spawn(task32, proc, [true]),
	Proc_2 = spawn(task32, proc, [false]),
	Proc_3 = spawn(task32, proc, [true]),
	ProcList = [Proc_1, Proc_2, Proc_3],
	register(coord, spawn(task32, coordinator, ["txn1", ProcList, 0, 1, 3000])).
