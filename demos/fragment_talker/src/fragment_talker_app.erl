-module(fragment_talker_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    fragment_talker_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
