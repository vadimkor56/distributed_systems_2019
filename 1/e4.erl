% Week 1, Exercise 4: Vector timestamps.

% This implementation is hard coded for exactly two processes (process/2).
% The main process (start/0) is not part of the simulated distributed system, but instead activates
% the distributed processes and tells them what to do.

% Start the program by calling start().

-module(e4).

-export([process/2, start/0]).

% Returns the given list with its Nth element incremented by one.
increment_list_at(List, N) ->
    Old_value = lists:nth(N, List),
    lists:sublist(List, N - 1) ++ [Old_value + 1] ++ lists:nthtail(N, List).

% Returns list L where L[i] = max(L1[i], L2[i]).
max_list(L1, L2) ->
    lists:map(fun(I) -> max(lists:nth(I, L1), lists:nth(I, L2)) end, lists:seq(1, length(L1))).

% Process function for a single process, starting with a timestamp for the process.
process(Process_Number, My_Timestamp) ->
    % To create varying execution orders in our program, sleep a random amount of time.
    timer:sleep(rand:uniform(100)),
    receive
        {command_to_send, Target_PID} -> % Received a command to send Target_PID a message.
            Sending_Event_Timestamp = increment_list_at(My_Timestamp, Process_Number),
            io:format("~w sends message with timestamp ~w~n", [Process_Number, Sending_Event_Timestamp]),
            Target_PID ! {message, Sending_Event_Timestamp},
            process(Process_Number, Sending_Event_Timestamp);
        {message, Message_Timestamp} -> % Received a message from another process.
            Receiving_Event_Timestamp = increment_list_at(max_list(My_Timestamp, Message_Timestamp), Process_Number),
            io:format("~w with timestamp ~w received a message with timestamp ~w. Thus event timestamp is ~w.~n", [Process_Number, My_Timestamp, Message_Timestamp, Receiving_Event_Timestamp]),
            process(Process_Number, Receiving_Event_Timestamp)
    end.

% Commands P1 and P2 to randomly send each other a message N times.
random_send(_, _, 0) -> done;
random_send(P1, P2, N) ->
    case rand:uniform(2) of
        1 -> P1 ! {command_to_send, P2};
        _ -> P2 ! {command_to_send, P1}
    end,
    % To create varying execution orders in our program, sleep a random amount of time.
    timer:sleep(rand:uniform(100)),
    random_send(P1, P2, N-1).

start() ->
    % Start two processes and randomly command them to send a few messages to each other.

    P1 = spawn(e4, process, [1, [0, 0]]),
    P2 = spawn(e4, process, [2, [0, 0]]),

    random_send(P1, P2, 10).
