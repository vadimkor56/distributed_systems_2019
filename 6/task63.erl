% ATTENTION!!!
% Firstly generate files with keys with these lines in the shell:
%
% openssl genrsa -out private1.pem 2048
% openssl rsa -in private1.pem -out public1.pem -outform PEM -pubout
%
% openssl genrsa -out private2.pem 2048
% openssl rsa -in private2.pem -out public2.pem -outform PEM -pubout

-module(task63).
-export([start/0, proc/3]).

proc(ID, SKey, PKeyList) ->
	receive
		{send, Msg, Receiver} ->
			Signature = public_key:sign(Msg, sha256, SKey),
			Receiver ! {msg, Msg, Signature, ID};
		{msg, Msg, Signature, SenderID} ->
			io:format("~p received msg ~p~nTrying to verify...~n", [self(), Msg]),
			IsVerified = public_key:verify(Msg, sha256, Signature, lists:nth(SenderID, PKeyList)),
			if
				IsVerified ->
					io:format("~p verified the msg ~p with the given signature~n", [self(), Msg]);
				true ->
					io:format("~p did NOT verify the msg ~p with the given signature~n", [self(), Msg])
			end
	end,
	proc(ID, SKey, PKeyList).

start() ->
	% Generated files with keys with:
	% openssl genrsa -out private.pem 2048
	% openssl rsa -in private.pem -out public.pem -outform PEM -pubout

  {ok, RawSKey1} = file:read_file("private1.pem"),
  {ok, RawPKey1} = file:read_file("public1.pem"),

	[EncSKey1] = public_key:pem_decode(RawSKey1),
  SKey1 = public_key:pem_entry_decode(EncSKey1),

  [EncPKey1] = public_key:pem_decode(RawPKey1),
  PKey1 = public_key:pem_entry_decode(EncPKey1),

	{ok, RawSKey2} = file:read_file("private1.pem"),
  {ok, RawPKey2} = file:read_file("public1.pem"),

	[EncSKey2] = public_key:pem_decode(RawSKey2),
  SKey2 = public_key:pem_entry_decode(EncSKey2),

  [EncPKey2] = public_key:pem_decode(RawPKey2),
  PKey2 = public_key:pem_entry_decode(EncPKey2),

	Proc1 = spawn(task63, proc, [1, SKey1, [PKey1, PKey2]]),
	Proc2 = spawn(task63, proc, [2, SKey2, [PKey1, PKey2]]),

	Proc1 ! {send, <<"hello crypto world">>, Proc2},
	timer:sleep(300),
	Proc1 ! {send, <<"Pad is 12ishiyr72TY873TGKY8HHA...">>, Proc2},
	timer:sleep(300),
	Proc1 ! {send, <<"Byzantine generals is known to be a hard problem">>, Proc2}.
