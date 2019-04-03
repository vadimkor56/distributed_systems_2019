% 0 - Pinni B
% 1 - Main Building

-module(task64).
-export([start/0, proc/5]).

proc(ID, Type, Votes, ProcList, Flag) ->
	VotesLength = length(Votes),
	ProcListLength = length(ProcList) + 1,
	if
		VotesLength ==  ProcListLength ->
			SumOfVotes = lists:sum(Votes),
			Half = VotesLength/2,
			if
				 SumOfVotes > Half ->
					io:format("~p decided Main Building~n", [self()]);
				true ->
					io:format("~p decided Pinni B~n", [self()])
			end;
		true ->
			nop
	end,

	receive
		{vote, Vote} ->
			io:format("~p received vote for ~p~n", [self(), Vote]),
			timer:sleep(ID * 200),
			if
				Flag == 0 ->
					case Type of
						"Correct" ->
							io:format("~p is correct and votes for ~p~n", [self(), Vote]),
							[Proc ! {vote, Vote} || Proc <- ProcList],
							NewVotes = lists:append(Votes, [Vote, Vote]);
						"Faulty" ->
							NewVote = abs(Vote - 1),
							io:format("~p is faulty and votes for ~p~n", [self(), NewVote]),
							[Proc ! {vote, NewVote} || Proc <- ProcList],
							NewVotes = lists:append(Votes, [Vote, NewVote]);
						"Random" ->
							NewVote = rand:uniform(2) - 1,
							io:format("~p is random and votes for ~p~n", [self(), NewVote]),
							[Proc ! {vote, NewVote} || Proc <- ProcList],
							NewVotes = lists:append(Votes, [Vote, NewVote])
					end,
					proc(ID, Type, NewVotes, ProcList, 1);
				true ->
					NewVotes = lists:append(Votes, [Vote]),
					proc(ID, Type, NewVotes, ProcList, Flag)
			end;
		{proc_list, NewProcList} ->
			proc(ID, Type, Votes, NewProcList, Flag);
		{start_voting, ForWhat} ->
			[Proc ! {vote, ForWhat} || Proc <- ProcList],
			NewVotes = lists:append(Votes, [ForWhat]),
			proc(ID, Type, NewVotes, ProcList, 1)
	end.

start_vote(Who, ForWhat) ->
	Who ! {start_voting, ForWhat}.

start() ->
	Proc1 = spawn(task64, proc, [1, "Correct", [], [1], 0]),
	Proc2 = spawn(task64, proc, [2, "Faulty", [], [1], 0]),
	Proc3 = spawn(task64, proc, [3, "Random", [], [1], 0]),
	Proc4 = spawn(task64, proc, [4, "Correct", [], [1], 0]),
	Proc5 = spawn(task64, proc, [5, "Faulty", [], [1], 0]),

	Proc1 ! {proc_list, [Proc2, Proc3, Proc4, Proc5]},
	Proc2 ! {proc_list, [Proc1, Proc3, Proc4, Proc5]},
	Proc3 ! {proc_list, [Proc1, Proc2, Proc4, Proc5]},
	Proc4 ! {proc_list, [Proc1, Proc2, Proc3, Proc5]},
	Proc5 ! {proc_list, [Proc1, Proc2, Proc3, Proc4]},

	timer:sleep(1000),
	start_vote(Proc1, 1).
