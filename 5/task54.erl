-module(task54).
-export([start/0, server/0, client/0]).

server() ->  %supervised server
	keep_alive(fun() -> register(server, self()),
											 receive
												 {Pid, Op, N, M} ->
													 case Op of
													 	"+" ->
													 		Res = N + M;
														"-" ->
													 		Res = N - M;
														"*" ->
													 		Res = N * M;
														"/" ->
													 		Res = N / M
													 end,
													 Pid ! {ans, Res, Op, N, M}
											 end
						 end
).

client() ->
	N = rand:uniform(100) - 1,
	M = rand:uniform(100) - 1,
	receive
		{req, Op} ->
			server ! {self(), Op, N, M};
		{ans, Answer, Op, N_, M_} ->
			io:format("The answer is ~p (~p~p~p) ~n", [Answer, N_, Op, M_])
	end,
	client().

keep_alive(Fun) ->
	Pid = spawn(Fun),
	on_exit(Pid, fun(_) -> keep_alive(Fun) end).


on_exit(Pid, Fun) ->
	spawn(fun() -> process_flag(trap_exit, true),
								 link(Pid),
								 receive
									 {'EXIT', Pid, Why} ->
										 Fun(Why)
									end
				end).

start() ->
	server(),
	Client = spawn(task54, client, []),
	Client ! {req, "-"},
	timer:sleep(1000),
	Client ! {req, "+"},
	timer:sleep(1000),
	Client ! {req, "*"},
	timer:sleep(1000),
	Client ! {req, "/"}.
