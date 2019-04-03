-module(tsk12_test).
-export([start/0, process_A/2, process_B/2]).

process_A(Send, 0) ->
    done;
process_A(Send, Message_A) ->
    io:format("~p~n", [What_A]),
    process_A(Send, Message_A - 1).

process_A(Receive, 0) ->
    done;
process_A(Receive, Message_A) ->
    io:format("~p~n", [What_A]),
    process_A(Send, Message_A - 1).

process_B(Send, 0) ->
    done;
process_B(Send, Message_B) ->
    io:format("~p~n", [What_B]),
    process_B(Send, Message_B - 1).

process_B(Receive, 0) ->
    done;
process_B(Receive, Message_B) ->
    io:format("~p~n", [What_B]),
    process_B(Send, Message_B - 1).


start() ->
    spawn(tsk12_test, process_A, [New_message_A, 3]),
    spawn(tsk12_test, process_A, [Old_message_A, 3]).
    spawn(tsk12_test, process_B, [New_message_B, 3]),
    spawn(tsk12_test, process_B, [Old_message_B, 3]).
