-module(task52).
-export([start/0, coordinator/5, proc/1]).

coordinator(TxnToCommit, ProcList, NumOfYes, Cnt, Timeout) ->
	if
		NumOfYes == length(ProcList) ->
			[Proc ! {commit, TxnToCommit} || Proc <- ProcList],
			coordinator(TxnToCommit, ProcList, 0, 0, 1000000);
		true ->
			nop
	end,

	if
		Cnt == 1 ->
			[ Proc ! {vote_req, TxnToCommit} || Proc <- ProcList ];
		true ->
			nop
	end,
	receive
		{ans, Ans} ->
			if
				Ans == 0 ->
					[Proc ! {rollback, TxnToCommit} || Proc <- ProcList];
				true ->
					coordinator(TxnToCommit, ProcList, NumOfYes + 1, 0, Timeout)
			end
	after Timeout ->
		io:format("Coordinator timed out. Sending rollbacks...~n"),
		[Proc ! {rollback, TxnToCommit} || Proc <- ProcList],
		coordinator(TxnToCommit, ProcList, 0, 0, 1000000)
	end.

proc(IsOk) ->
	receive
		{vote_req, TxnToCommit} ->
			io:format("Proc ~p received vote-req for txn ~p~n", [self(), TxnToCommit]),

			timer:sleep(rand:uniform(4000)),
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
			io:format("Proc ~p is aborting txn~p~n", [self(), Txn]);
		{commit, Txn} ->
			% io:format("Here", []),
			io:format("Proc ~p is commiting txn~p~n", [self(), Txn])
	end.


start() ->
	Proc_1 = spawn(task52, proc, [true]),
	Proc_2 = spawn(task52, proc, [true]),
	Proc_3 = spawn(task52, proc, [true]),
	ProcList = [Proc_1, Proc_2, Proc_3],
	register(coord, spawn(task52, coordinator, ["txn1", ProcList, 0, 1, 2000])).
