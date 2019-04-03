-module(task21).
-export([start/0, proc_1/4, proc_2/4, proc_3/4]).

proc_1(ID, State, Coordinator, Group) ->
	if
		State /= "Normal" ->
			timer:sleep(100 * ID),
			if
				ID == Coordinator ->
					proc_3 ! {ID, Group},
					proc_2 ! {ID, Group};
				true ->
					proc_1(ID, State, Coordinator, Group)
			end;
		true ->
			io:format("End~n", [])
	end,

	receive
		{OfferedCoord, OfferedGroup} ->
			io:format("Process ~p offered process ~p, which is in group ~p, to join the group ~p~n", [OfferedCoord, ID, Group, OfferedGroup]),

			if
				Coordinator < OfferedCoord ->
					io:format("Process ~p decided to join the group ~p~n", [ID, OfferedGroup]),
					proc_2 ! {OfferedCoord, OfferedGroup, Group},
					proc_3 ! {OfferedCoord, OfferedGroup, Group},

					case OfferedCoord of
						2 ->
							proc_2 ! {OfferedGroup ++ Group};
						3 ->
							proc_3 ! {OfferedGroup ++ Group}
					end,


					proc_1(ID, State, OfferedCoord, OfferedGroup ++ Group);

				true ->
					io:format("Process ~p declined the offer to join the group ~p~n", [ID, OfferedGroup]),
					proc_1(ID, State, Coordinator, Group)
			end;

		{NewCoord, NewGroup, Group_} ->
			Len = string:length(NewGroup ++ Group),
			if
				Group /= Group_ ->
					proc_1(ID, State, Coordinator, Group);
				Len == 3 ->
					proc_1(ID, "Normal", NewCoord, NewGroup ++ Group);
				true ->
					proc_1(ID, State, NewCoord, NewGroup ++ Group)
			end;

		{AcceptedGroup} ->
			Len = string:length(AcceptedGroup),
			io:format("Process ~p now is the coordinator of group ~p~n", [ID, AcceptedGroup]),
			if Len == 3 ->
				io:format("Process ~p is the coordinator of everyone~n", [ID]),
				proc_1(ID, "Normal", Coordinator, AcceptedGroup);
			true ->
				proc_1(ID, State, Coordinator, AcceptedGroup)
			end
	end.

proc_2(ID, State, Coordinator, Group) ->
	if
		State /= "Normal" ->
			timer:sleep(100 * ID),
			if
				ID == Coordinator ->
					proc_1 ! {ID, Group},
					proc_3 ! {ID, Group};
				true ->
					proc_2(ID, State, Coordinator, Group)
			end;
		true ->
			io:format("End~n", [])
	end,

	receive
		{OfferedCoord, OfferedGroup} ->
			io:format("Process ~p offered process ~p, which is in group ~p, to join the group ~p~n", [OfferedCoord, ID, Group, OfferedGroup]),

			if
				Coordinator < OfferedCoord ->
					io:format("Process ~p decided to join the group ~p~n", [ID, OfferedGroup]),
					proc_1 ! {OfferedCoord, OfferedGroup, Group},
					proc_3 ! {OfferedCoord, OfferedGroup, Group},

					case OfferedCoord of
						1 ->
							proc_1 ! {OfferedGroup ++ Group};
						2 ->
							proc_2 ! {OfferedGroup ++ Group};
						3 ->
							proc_3 ! {OfferedGroup ++ Group}
					end,

					proc_2(ID, State, OfferedCoord, OfferedGroup ++ Group);

				true ->
					io:format("Process ~p declined the offer to join the group ~p~n", [ID, OfferedGroup]),
					proc_2(ID, State, Coordinator, Group)
			end;

		{NewCoord, NewGroup, Group_} ->
			Len = string:length(NewGroup ++ Group),
			if
				Group /= Group_ ->
					proc_2(ID, State, Coordinator, Group);
				Len == 3 ->
					proc_2(ID, "Normal", NewCoord, NewGroup ++ Group);
				true ->
					proc_2(ID, State, NewCoord, NewGroup ++ Group)
			end;

		{AcceptedGroup} ->
			Len = string:length(AcceptedGroup),
			io:format("Process ~p now is the coordinator of group ~p~n", [ID, AcceptedGroup]),
			if Len == 3 ->
				io:format("Process ~p is the coordinator of everyone~n", [ID]),
				proc_2(ID, "Normal", Coordinator, AcceptedGroup);
			true ->
				proc_2(ID, State, Coordinator, AcceptedGroup)
			end
	end.


proc_3(ID, State, Coordinator, Group) ->
	if
		State /= "Normal" ->
			timer:sleep(100 * ID),
			if
				ID == Coordinator ->
					proc_1 ! {ID, Group},
					proc_2 ! {ID, Group};
				true ->
					proc_3(ID, State, Coordinator, Group)
			end;
			true ->
				io:format("End~n", [])
	end,

	receive
		{OfferedCoord, OfferedGroup} ->
			io:format("Process ~p offered process ~p, which is in group ~p, to join the group ~p~n", [OfferedCoord, ID, Group, OfferedGroup]),

			if
				Coordinator < OfferedCoord ->
					io:format("Process ~p decided to join the group ~p~n", [ID, OfferedGroup]),
					proc_2 ! {OfferedCoord, OfferedGroup, Group},
					proc_1 ! {OfferedCoord, OfferedGroup, Group},

					case OfferedCoord of
						1 ->
							proc_1 ! {OfferedGroup ++ Group};
						2 ->
							proc_2 ! {OfferedGroup ++ Group};
						3 ->
							proc_3 ! {OfferedGroup ++ Group}
					end,

					proc_1(ID, State, OfferedCoord, OfferedGroup ++ Group);

				true ->
					io:format("Process ~p declined the offer to join the group ~p~n", [ID, OfferedGroup]),
					proc_3(ID, State, Coordinator, Group)
			end;

		{NewCoord, NewGroup, Group_} ->
			Len = string:length(NewGroup ++ Group),
			if
				Group /= Group_ ->
					proc_3(ID, State, Coordinator, Group);
				Len == 3 ->
					proc_3(ID, "Normal", NewCoord, NewGroup ++ Group);
				true ->
					proc_3(ID, State, NewCoord, NewGroup ++ Group)
			end;

		{AcceptedGroup} ->
			Len = string:length(AcceptedGroup),
			io:format("Process ~p now is the coordinator of group ~p~n", [ID, AcceptedGroup]),
			if Len == 3 ->
				io:format("Process ~p is the coordinator of everyone~n", [ID]),
				proc_3(ID, "Normal", Coordinator, AcceptedGroup);
			true ->
				proc_2(ID, State, Coordinator, AcceptedGroup)
			end
	end.



start() ->
  register(proc_1, spawn(task21, proc_1, [1, "Reorganization", 1, "1"])),
	register(proc_2, spawn(task21, proc_2, [2, "Reorganization", 2, "2"])),
	register(proc_3, spawn(task21, proc_3, [3, "Reorganization", 3, "3"])).
