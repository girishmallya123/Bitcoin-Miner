-module(bitcoin_miner).
-import(lists,[nth/2]).
-import(string,[left/3, concat/2]).
-export([main/1 , start_mine/2]).

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

mine(_, false, Pid) ->
    send_message(Pid, {stop, Pid}),
    start_mine(0, false),
    ok;

mine(I, Flag, Pid) ->
            String_Characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
            Random_String = get_random_string(32, String_Characters),
            Input_String = concat("girish.mallya", Random_String),
            Hashed_String =io_lib:format("~64.16.0b", [binary:decode_unsigned(crypto:hash(sha256, Input_String))]),
            Prefix = left("",I,$0), 
            Status = prefix(Prefix, Hashed_String),
            if 
                Status == true ->
                    io:format("~s\t~s~n", [Input_String, Hashed_String]),
                    mine(I, false, Pid);
                true ->
                    mine(I, Flag, Pid)
            end.
            
send_message(Pid, Msg) ->
    Pid ! Msg.

start_mine(I, Flag) ->
    receive 
        {start, S} ->
            mine(I, Flag, S);
        {stop, _} ->
            exit(0)
    end.

spawn_miners(I, 0) ->
    io:format("~w~n",[I]),
    ok;

spawn_miners(I, K) ->
    io:format("Spawning miner number ~w~n", [K]),
    S = spawn(bitcoin_miner, start_mine, [I, true]),
    send_message(S, {start, S}),
    spawn_miners(I, K-1).

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

    spawn_miners(I, 10),
    timer:sleep(30000).