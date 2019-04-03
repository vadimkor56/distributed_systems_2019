-module(tsk13_test).
-export([test/0, lamport/1,lamport/2]).
lamport(Time)->
    receive
        {start, Pid_other} ->
            io:format("start~n"),
            Pid_other ! {ping, Time+1},
            lamport(Time +1,Pid_other)
    end.

lamport(Time, Other_pid) ->
    if
        Time > 10 ->
            io:format("poison pill ~p~n", [self()]);
        true->
        receive
            {ping, Other_time} ->
                io:format("ping received ~p~n",[max(Other_time,Time)+1]),
                timer:sleep(5000),
                Other_pid ! {ping, max(Time,Other_time)},
                lamport(max(Time,Other_time)+1,Other_pid)
        end
    end.

%max(Left,Right) ->
%    if
%        Left > Right ->
%            Left;
%        true ->
%            Right
%    end.
test() ->
    A_PID = spawn(tsk13_test, lamport, [0]),
    B_PID = spawn(tsk13_test,lamport,[0, A_PID]),
    A_PID ! {start, B_PID}.
