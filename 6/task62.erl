% ATTENTION!!!
% Firstly generate files with keys with these lines in the shell:
%
% openssl genrsa -out private1.pem 2048
% openssl rsa -in private1.pem -out public1.pem -outform PEM -pubout
%
% openssl genrsa -out private2.pem 2048
% openssl rsa -in private2.pem -out public2.pem -outform PEM -pubout
% 
% openssl genrsa -out private3.pem 2048
% openssl rsa -in private3.pem -out public3.pem -outform PEM -pubout

-module(task62).
-export([start/0, proc/3]).

proc(ID, SKey, PKeyList) ->
	receive
		{send, Msg, Receiver} ->
			EncMsg = public_key:encrypt_private(Msg, SKey),
			Receiver ! {msg, EncMsg, ID};
		{msg, EncMsg, SenderID} ->
			io:format("~p received encryped msg ~p~n", [self(), EncMsg]),
			Msg = public_key:decrypt_public(EncMsg, lists:nth(SenderID, PKeyList)),
			io:format("~p decrypted msg: ~p~n", [self(), Msg])
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

	{ok, RawSKey3} = file:read_file("private1.pem"),
  {ok, RawPKey3} = file:read_file("public1.pem"),

	[EncSKey3] = public_key:pem_decode(RawSKey3),
  SKey3 = public_key:pem_entry_decode(EncSKey3),

  [EncPKey3] = public_key:pem_decode(RawPKey3),
  PKey3 = public_key:pem_entry_decode(EncPKey3),

	Proc1 = spawn(task62, proc, [1, SKey1, [PKey1, PKey2, PKey3]]),
	Proc2 = spawn(task62, proc, [2, SKey2, [PKey1, PKey2, PKey3]]),
	Proc3 = spawn(task62, proc, [3, SKey3, [PKey1, PKey2, PKey3]]),

	Proc1 ! {send, <<"hello crypto world">>, Proc2},
	timer:sleep(300),
	Proc2 ! {send, <<"Pad is 12ishiyr72TY873TGKY8HHA...">>, Proc3},
	timer:sleep(300),
	Proc3 ! {send, <<"Byzantine generals is known to be a hard problem">>, Proc1}.
