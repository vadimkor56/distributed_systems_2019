-module(ex4_test).

-include_lib("eunit/include/eunit.hrl").

% -export([
%    base_test/0,
%    merge_test/0,
%    older_test/0,
%    compare_test/0]).

base_test() ->
    ?assertEqual(0, ex4_main:get_counter(aaa, ex4_main:new())),
    VC = ex4_main:increment(aaa, ex4_main:new()),
    ?assertEqual(1, ex4_main:get_counter(aaa, VC)).

merge_test() ->
    A = ex4_main:increment(a, ex4_main:new()),
    B = ex4_main:increment(b, ex4_main:new()),
    ?assertEqual([a, b], ex4_main:get_nodes(ex4_main:merge(A, B))),
    A2 = ex4_main:increment(a, A),
    M = ex4_main:merge(A2, B),
    ?assertEqual(2, ex4_main:get_counter(a, M)),
    C = ex4_main:new(),
    M2 = ex4_main:merge(M, ex4_main:increment(c, C)),
    M2a = ex4_main:increment(a, M2),
    ?assertEqual(3, ex4_main:get_counter(a, M2a)),
    ?assertEqual(1, ex4_main:get_counter(c, M2a)).

older_test() ->
    A = ex4_main:increment(a, ex4_main:new()),
    B = ex4_main:increment(b, ex4_main:new()),
    M = ex4_main:merge(A, B),
    ?assert(ex4_main:descends(M, A)),
    C = ex4_main:increment(c, ex4_main:new()),
    M2 = ex4_main:merge(C, M),
    ?assert(ex4_main:descends(M2, M)).

compare_test() ->
    M = ex4_main:merge(ex4_main:increment(a, ex4_main:new()), ex4_main:increment(b, ex4_main:new())),
    A = ex4_main:increment(a, M),
    timer:sleep(10),
    B = ex4_main:increment(b, M),
    B2 = ex4_main:increment(b, B),
    ?assertNot(ex4_main:descends(A, B)),
    ?assertNot(ex4_main:descends(B, A)),
    ?assert(ex4_main:compare(A, B)),
    timer:sleep(10),
    C = ex4_main:increment(c, ex4_main:new()),
    C2 = ex4_main:increment(c, C),
    ?assertNot(ex4_main:descends(A, C)),
    ?assertNot(ex4_main:descends(C, A)),
    ?assertEqual([A, B, B2, C, C2], lists:sort(fun ex4_main:compare/2, [C2, B, A, C, B2])).
