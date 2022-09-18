-module(bitcoin_miner).
-import(lists,[nth/2]).
-import(string,[left/3]).
-export([main/1]).

prefix([], _) -> true;
    prefix([Ch | Rest1], [Ch | Rest2]) ->
        prefix(Rest1, Rest2);
    prefix(_, _) -> false.

get_random_string(Length, AllowedChars) ->
    lists:foldl(fun(_, Acc) ->
                        [lists:nth(rand:uniform(length(AllowedChars)),
                                   AllowedChars)]
                            ++ Acc
                end, [], lists:seq(1, Length)).

mine(0, false) ->
    ok;

mine(I, Flag) ->
    String_Characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
    Random_String = get_random_string(32, String_Characters),
    Hashed_String =io_lib:format("~64.16.0b", [binary:decode_unsigned(crypto:hash(sha256, Random_String))]),
    Prefix = left("",I,$0), 
    Status = prefix(Prefix, Hashed_String),
    if 
        Status == true ->
            io:format("Found a bitcoin!~n"),
            mine(0, false);
        true ->
            io:format("Mining~n"),
            mine(I, Flag)
    end.
    
main(Args) ->
    N = hd(Args),
    I = list_to_integer(atom_to_list(N)),
    
    if
        length(Args) > 1 ->
            io:write("Invalid arguments"),
            erlang:halt(0);
        true ->
            io:format("Required number of leading 0's: ~w~n", [N])
    end,
    mine(I, true).