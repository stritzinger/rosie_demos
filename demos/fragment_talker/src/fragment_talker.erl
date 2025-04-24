-module(fragment_talker).

-export([start_link/0]).

-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).

-include_lib("std_msgs/src/_rosie/std_msgs_byte_multi_array_msg.hrl").

-record(state, {ros_node, publisher}).

start_link() ->
    gen_server:start_link(?MODULE, [], []).

init(_) ->
    Node = ros_context:create_node("fragment_talker"),
    Pub = ros_node:create_publisher(Node,
                                   std_msgs_byte_multi_array_msg,
                                   "fragmented_data"),

    % Start sending messages periodically
    erlang:send_after(1000, self(), send_message),
    {ok, #state{ros_node = Node, publisher = Pub}}.

handle_call(_, _, S) ->
    {reply, ok, S}.

handle_cast(_, S) ->
    {noreply, S}.

handle_info(send_message, #state{publisher = Pub} = S) ->
    ByteSize = 1000 * 20, % 1MB
    % Create a large byte array (1MB)
    Data = lists:seq(1, ByteSize),
    Layout = #std_msgs_multi_array_layout{
        dim = [#std_msgs_multi_array_dimension{
            label = "data",
            size = ByteSize,
            stride = 1
        }],
        data_offset = 0
    },
    % Create the message
    Msg = #std_msgs_byte_multi_array{
        layout = Layout,
        data = Data
    },

    io:format("ROSIE: [frag_talker]: I am sending a byte array of length: ~p\n", [length(Data)]),
    % Publish the message
    ros_publisher:publish(Pub, Msg),

    % Schedule next message
    erlang:send_after(3000, self(), send_message),

    {noreply, S};
handle_info(_, S) ->
    {noreply, S}.
