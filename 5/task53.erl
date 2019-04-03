-module(task53).
-export([start/0, coordinator/5, proc/2]).

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
		coordinator(TxnToCommit, ProcList, NumOfYes, 0, 1000000)
	end.

proc(IsOk, State) ->
	if
		State == "ok" ->
			nop;
		State == "crashed" ->
			io:format("~p crashed~n", [self()]),
			Pid = self(),
			supervisor(Pid, IsOk)
	end,

	receive
		{vote_req, TxnToCommit} ->
			io:format("Proc ~p received vote-req for txn ~p~n", [self(), TxnToCommit]),
			Crash = rand:uniform(2) - 1,
			% io:format("~p~n", [Crash]),
			if
				Crash == 0 ->
					nop;
				true ->
					proc(IsOk, "crashed")
			end,

			if
				State == "ok" ->
					if
						IsOk ->
							io:format("Proc ~p is sending Yes to the coordinator ~n", [self()]),
							coord ! {ans, 1};
						true ->
							io:format("Proc ~p is sending No to the coordinator ~n", [self()]),
							coord ! {ans, 0}
					end;
				true ->
					nop
			end,

			proc(IsOk, State);
		{rollback, Txn} ->
			io:format("Proc ~p is aborting txn~p~n", [self(), Txn]),
			exit(self(), normal);
		{commit, Txn} ->
			io:format("Proc ~p is commiting txn~p~n", [self(), Txn]),
			exit(self(), normal);
		sendYes ->
			io:format("Proc ~p recovered and now sending Yes to the coordinator~n", [self()]),
			coord ! {ans, 1},
			proc(IsOk, "ok");
		sendNo ->
			io:format("Proc ~p recovered and now sending No to the coordinator~n", [self()]),
			coord ! {ans, 0},
			proc(IsOk, "ok")
	end.


supervisor(Pid, Ans) ->
	if
	 		Ans ->
				Pid ! sendYes;
			true ->
				Pid ! sendNo
	end.

start() ->
	Proc_1 = spawn(task53, proc, [true, "ok"]),
	Proc_2 = spawn(task53, proc, [true, "ok"]),
	Proc_3 = spawn(task53, proc, [true, "ok"]),
	ProcList = [Proc_1, Proc_2, Proc_3],
	register(coord, spawn(task53, coordinator, ["txn1", ProcList, 0, 1, 5000])),
	timer:sleep(5000),
	unregister(coord).
