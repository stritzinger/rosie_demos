-module(fragment_listener).

-export([start_link/0]).

-behaviour(gen_subscription_listener).
-export([on_topic_msg/2]).

-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2]).

-include_lib("std_msgs/src/_rosie/std_msgs_byte_multi_array_msg.hrl").

-record(state, {subscription}).

start_link() ->
    gen_server:start_link(?MODULE, [], []).

on_topic_msg(Pid, Msg) ->
    gen_server:cast(Pid, {on_topic_msg, Msg}).

init(_) ->
    Node = ros_context:create_node("fragment_listener"),
    Sub = ros_node:create_subscription(Node,
                                       std_msgs_byte_multi_array_msg,
                                       "fragmented_data",
                                       {?MODULE, self()}),
    {ok, #state{subscription = Sub}}.

handle_call(_, _, S) ->
    {reply, ok, S}.

handle_cast({on_topic_msg, #std_msgs_byte_multi_array{data = Msg}}, S) ->
    io:format("ROSIE: [frag_listener]: I receive a byte array of length: ~p\n", [length(Msg)]),
    {noreply, S};
handle_cast(C, S) ->
    io:format("ROSIE: [frag_listener]: uhandled cast: ~p\n", [C]),
    {noreply, S}.
