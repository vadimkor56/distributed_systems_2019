-module(test).

%% API
-export([testCommitCancel/0]).

sendVoteRequests([]) -> done;
sendVoteRequests([Participant | Rest]) ->
  Participant ! {vote, self()},
  sendVoteRequests(Rest).

receiveVotes(0) -> #{};
receiveVotes(ParticipantCount) ->
  receive
    {commit, Participant} -> genCommitVote(Participant, ParticipantCount);
    {rollback, Participant} -> genRollbackVote(Participant, ParticipantCount);
    {cancel, Participant} -> genCancelVote(Participant, ParticipantCount)
  end.

genCommitVote(Participant, ParticipantCount) ->
  maps:merge(#{Participant => commit}, receiveVotes(ParticipantCount-1)).

genRollbackVote(Participant, ParticipantCount) ->
  maps:merge(
    #{
      Participant => rollback,
      rollback => true
    },
    receiveVotes(ParticipantCount-1)
  ).

genCancelVote(Participant, ParticipantCount) ->
  maps:merge(
    #{
      Participant => cancel,
      rollback => true
    },
    receiveVotes(ParticipantCount)
  ).

sendMessageToParticipants([], _) -> [];
sendMessageToParticipants([Participant | Rest], Message) ->
  Participant ! Message,
  sendMessageToParticipants(Rest, Message).

sendVoteResults(ParticipantVoteMap) ->
  case maps:is_key(rollback, ParticipantVoteMap) of
    true  ->
      Committers = maps:filter(fun(_, V) -> (V == commit) or (V == cancel) end, ParticipantVoteMap),
      sendMessageToParticipants(maps:keys(Committers), rollback);
    false ->
      sendMessageToParticipants(maps:keys(ParticipantVoteMap), commit)
  end.

initCoordinator(ParticipantList) ->
  sendVoteRequests(ParticipantList),
  ParticipantVoteMap = receiveVotes(length(ParticipantList)),
  sendVoteResults(ParticipantVoteMap).

receiveVoteResult() ->
  receive
    commit -> io:format("~w COMMITTING\n", [self()]);
    rollback -> io:format("~w ROLLING BACK\n", [self()])
  end.

attemptCancel(Coordinator) ->
  io:format("~w attempting to CANCEL\n", [self()]),
  Coordinator ! {cancel, self()}.

% Committers have to wait for response from coordinator
% Cancel as a param only for the exercises sake
sendCommitVote(Coordinator, Cancel) ->
  io:format("~w voting for COMMIT\n", [self()]),
  Coordinator ! {commit, self()},
  case Cancel of
    false -> receiveVoteResult();
    true  -> attemptCancel(Coordinator), receiveVoteResult()
  end.

% Rollbackers continue regular execution
sendRollbackVote(Coordinator) ->
  io:format("~w voting for ROLLBACK\n", [self()]),
  Coordinator ! {rollback, self()},
  io:format("~w ROLLING BACK\n", [self()]).

% For the exercises sake, participants receive their votes as a parameter
initParticipant(Vote) ->
  receive
    {vote, Coordinator} ->
      case Vote of
        % A one second wait 1000 so the cancellation will always make it before all commits
        commit   -> receive after 1000 -> ok end,sendCommitVote(Coordinator, false);
        rollback -> sendRollbackVote(Coordinator);
        cancel   -> sendCommitVote(Coordinator, true)
      end
  end.

testCommitCancel() ->
  Participant1PID = spawn(fun() -> initParticipant(cancel) end),
  Participant2PID = spawn(fun() -> initParticipant(commit) end),
  spawn(fun() -> initCoordinator([Participant1PID, Participant2PID]) end).
