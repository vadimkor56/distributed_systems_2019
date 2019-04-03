-module(test).
-export([divider/0]).

divider() ->
	keep_alive(fun() -> register(divider,self()),
											 receive
												 N -> io:format("~n~p~n",[1/N])
											 end
						 end
).

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
