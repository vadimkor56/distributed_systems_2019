-module(test).

% Main takes the number of threads wanted as a parameter.
% If this crashes, run main again, ets doesn't clear in memory storage
% when main is finished if the erlang runtime is still running in the same instance.

% For exercise 4, I created logging storage for assumption:
%
% All sites in our system have some form of safe storage that is capable
% of surviving system crashes.
%
% Now every spawned process (aka. site) will store their actions in a log file.
% The log files are in format <storage: value>, and named by the processes that created them

%% API
-export([main/1]).

-record(store, {locked=false, data}).

new(Name) -> ets:new(Name, [set, named_table, public]).
defaults(Table) -> ets:insert(Table, {data, 0}).
insert(Store, Data) -> ets:insert(Store#store.data, {data, Data}).
lookup(Store) -> ets:lookup(Store#store.data, data).

main(ThreadCount) ->
  T1 = new(t1),
  T2 = new(t2),
  T3 = new(t3),

  defaults(T1),
  defaults(T2),
  defaults(T3),

  Store1 = #store{data=T1},
  Store2 = #store{data=T2},
  Store3 = #store{data=T3},

  Parent = self(),
  spawnThreads(ThreadCount, [Store1, Store2, Store3], Parent),
  lock(ThreadCount).

spawnThreads(0, _, _) -> done;
spawnThreads(ThreadCount, StoreList, Parent) ->
  Store = lists:nth(rand:uniform(length(StoreList)), StoreList),
  Value = rand:uniform(100),
  spawn(fun() -> print_and_store(Store, Value, Parent) end),
  spawnThreads(ThreadCount-1, StoreList, Parent).

% prints the contents of a store and stores a new value
print_and_store(Store, NewValue, Parent) ->
  {ok, Fd} = file:open(io_lib:format("~wlog.txt", [self()]), [append]),
  file:write(Fd, io_lib:format("~p: ~w~n", [Store#store.data, NewValue])),
  Parent ! {lock, Store, self()},
  receive
    {locked, Store} ->
      if
        Store == Store ->
          io:format("Before insert: ~w\n", lookup(Store)),
          insert(Store, NewValue),
          io:format("After insert: ~w\n", lookup(Store))
      end
  end.

lock(0) -> done;
lock(Count) ->
  receive
    {lock, Store, LockerPID} ->
      if
        Store#store.locked == true ->
          receive
            {unlock, Store2} ->
              if
                Store2 == Store ->
                  LockerPID ! {locked, Store}
              end
          end;
        Store#store.locked == false ->
          LockerPID ! {locked, Store}
      end
  end,
  lock(Count-1).
