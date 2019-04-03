-module(test).
-export([data_proc/2, process/4, start_read_granted/0, start_read_not_granted/0, start_write_granted/0, start_write_not_granted/0]).

data_proc([{Data_item_1, Item1_RTS, Item1_WTS}], Iteration_Id) ->
    case (Iteration_Id == 0) of
      true ->
          io:format("**~n", []);
      false ->
          io:format("~w ~w ~w, Update complete~n", [Data_item_1, Item1_RTS, Item1_WTS])
    end,

    receive
         {{read_req, Proc_TS}, Proc_PID} ->
            case (Proc_TS >= Item1_RTS) of
             true ->
                   Proc_PID ! {{read_perm_granted, {"data_item_1",Item1_RTS, Item1_WTS}}, self()};
             false ->
                   Proc_PID ! {read_perm_not_granted, self()}
            end;

         {{write_req, Proc_TS}, Proc_PID} ->
            case (Proc_TS >= Item1_WTS) of
              true ->
                   Proc_PID ! {{write_perm_granted, {"data_item_1",Item1_RTS, Item1_WTS}}, self()};
             false ->
                   Proc_PID ! {write_perm_not_granted, self()}
            end
    end.
    % data_proc([{"data_item_1",Item1_RTS, Item1_WTS}], Iteration_Id).

process(Data_proc_PID, Proc_TS, Action_Id, Iteration_Id) ->
    case (Iteration_Id == 0) of
      true ->
        case (Action_Id == 0) of
           true ->
             Data_proc_PID ! {{read_req, Proc_TS}, self()},
             process(Data_proc_PID, Proc_TS + 1, Action_Id, 1);
           false ->
             Data_proc_PID ! {{write_req, Proc_TS}, self()},
             process(Data_proc_PID, Proc_TS + 1, Action_Id, 1)
        end;
      false ->
          io:format("*~n", [])
    end,

    receive
         {{read_perm_granted, {"data_item_1",Item1_RTS, Item1_WTS}}, Data_proc_PID} ->
            io:format("Read permission has been granted~n", []),
            io:format("Updating timestamps of respective data items...~n", []),
            data_proc([{"data_item_1",Item1_RTS + 1, Item1_WTS}], 1);
            % io:format("Update complete~n", []);

         {read_perm_not_granted, Data_proc_PID} ->
             io:format("Read permission has not been granted - timestamp conflict~n", []);

         {{write_perm_granted, {"data_item_1",Item1_RTS, Item1_WTS}}, Data_proc_PID} ->
            io:format("Write permission has been granted~n", []),
            io:format("Updating timestamps of respective data items...~n", []),
            data_proc([{"data_item_1_new_value",Item1_RTS, Item1_WTS + 1}], 1);
            % io:format("Update complete~n", []);

         {write_perm_not_granted, Data_proc_PID} ->
             io:format("Write permission has not been granted - timestamp conflict~n", [])
    end.

start_read_granted() ->
    Data_process_PID = spawn(test, data_proc, [[{"data_item_1", 0, 0}], 0]),
    spawn(test, process, [Data_process_PID, 0, 0, 0]).
    % spawn(test, coord, [PA_PID, PB_PID, 0, 0]).

start_read_not_granted() ->
    Data_process_PID = spawn(test, data_proc, [[{"data_item_1", 0, 0}], 0]),
    spawn(test, process, [Data_process_PID, -1, 0, 0]). % Timestamp given the value of -1 only for testing purposes
    % spawn(test, coord, [PA_PID, PB_PID, 0, 0]).

start_write_granted() ->
    Data_process_PID = spawn(test, data_proc, [[{"data_item_1", 0, 0}], 0]),
    spawn(test, process, [Data_process_PID, 0, 1, 0]).
    % spawn(test, coord, [PA_PID, PB_PID, 0, 0]).

start_write_not_granted() ->
    Data_process_PID = spawn(test, data_proc, [[{"data_item_1", 0, 0}], 0]),
    spawn(test, process, [Data_process_PID, -1, 1, 0]). % Timestamp given the value of -1 only for testing purposes
    % spawn(test, coord, [PA_PID, PB_PID, 0, 0]).
