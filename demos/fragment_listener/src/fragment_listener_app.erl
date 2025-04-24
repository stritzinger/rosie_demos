-module(fragment_listener_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    fragment_listener_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
