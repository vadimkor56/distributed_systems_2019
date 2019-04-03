-module(task31).
-export([vectorTs/2, runner/2, start/0]).

% comparator(Key, Value1, Value2) ->
% 	if
% 		Value1 > Value2 ->
% 			Value1;
% 		true ->
% 			Value2
% 	end.

vectorTs(ID, TSDict) ->
	receive
	    {msg, MsgTSDict} ->
					TSnew = dict:merge(fun(Key, Value1, Value2) ->
						if
							Value1 > Value2 ->
								Value1;
							true ->
								Value2
						end
					end,
					TSDict, MsgTSDict),
					TSnewest = dict:update_counter(ID, 1, TSnew),
	        io:format("~p: Receiving msg, new local timestamp: ~p~n", [ID, dict:to_list(TSnewest)]),
	  			vectorTs(ID, TSnewest);
	    {sendCmd, PID} ->
	        io:format("~p:Sending msg, new local timestamp: ~p~n", [ID, dict:to_list(dict:update_counter(ID, 1, TSDict))]),
	        PID ! {msg, dict:update_counter(ID, 1, TSDict)},
	  			vectorTs(ID, dict:update_counter(ID, 1, TSDict))
	end.

runner(PA_PID, PB_PID) ->
	PA_PID ! {sendCmd, PB_PID},
	PB_PID ! {sendCmd, PA_PID},
	PA_PID ! {sendCmd, PB_PID},
	PB_PID ! {sendCmd, PA_PID},
	PA_PID ! {sendCmd, PB_PID}.

start() ->
	PA_PID = spawn(task31, vectorTs, ["A", dict:from_list([{"A",0}])]),
	PB_PID = spawn(task31, vectorTs, ["B", dict:from_list([{"B",0}])]),
	spawn(task31, runner, [PA_PID, PB_PID]).
