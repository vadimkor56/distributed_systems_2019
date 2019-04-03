-module(task61).
-export([start/0, proc/0]).

pad() ->
"12ishiyr72TY873TGKY8HHAE7YT8YsadaHGFIYLIasdjasdgjasgd".

encrypt_0([H|T], [H1|T1]) ->
[H bxor H1 | encrypt_0(T, T1)];
encrypt_0(_, []) ->
[];
encrypt_0([],_) ->
[].

proc() ->
	receive
		{send, Msg, Receiver} ->
			EncMsg = encrypt_0(Msg, pad()),
			Receiver ! EncMsg;
		EncMsg ->
			io:format("~p received encryped msg ~p~n", [self(), EncMsg]),
			Msg = encrypt_0(EncMsg, pad()),
			io:format("~p decrypted msg: ~p~n", [self(), Msg])
	end,
	proc().

start() ->
	Proc1 = spawn(task61, proc, []),
	Proc2 = spawn(task61, proc, []),
	Proc3 = spawn(task61, proc, []),

	Proc1 ! {send, "Distributed systems", Proc2},
	timer:sleep(300),
	Proc2 ! {send, "Pad is 12ishiyr72TY873TGKY8HHA...", Proc3},
	timer:sleep(300),
	Proc3 ! {send, "Byzantine generals is known to be a hard problem", Proc1}.
