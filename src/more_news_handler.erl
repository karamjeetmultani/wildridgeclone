-module(more_news_handler).
-include("includes.hrl").
-export([init/3]).

-export([content_types_provided/2]).
-export([welcome/2]).
-export([terminate/3]).

%% Init
init(_Transport, _Req, []) ->
	{upgrade, protocol, cowboy_rest}.

%% Callbacks
content_types_provided(Req, State) ->
	{[		
		{<<"text/html">>, welcome}	
	], Req, State}.

terminate(_Reason, _Req, _State) ->
	ok.

%% API
welcome(Req, State) ->
	{PageBinary, _} = cowboy_req:qs_val(<<"p">>, Req),
	PageNum = list_to_integer(binary_to_list(PageBinary)),
	SkipItems = (PageNum-1) * ?NEWS_PER_PAGE,
	{CategoryBinary, _} = cowboy_req:qs_val(<<"c">>, Req),
	Category = binary_to_list(CategoryBinary),

	% Url_more_news = wildridgeclone_util:more_news(Category, integer_to_list(?NEWS_PER_PAGE), integer_to_list(SkipItems)), 	
	% {ok, "200", _, ResponseAllNews} = ibrowse:send_req(Url_more_news,[],get,[],[]),
	% ResAllNews = string:sub_string(ResponseAllNews, 1, string:len(ResponseAllNews) -1 ),
	% [{<<"total_rows">>,_},{<<"offset">>,_},{<<"rows">>,ParamsAllNews}] = jsx:decode(list_to_binary(ResAllNews)),
	
	Url_more_news = case Category of 
		"World" ->
			%Category = "US",
			string:concat("http://api.contentapi.ws/news?channel=us_world&limit=10&format=short&skip=",integer_to_list(SkipItems));
		"US" ->
			%Category = "US",
			string:concat("http://api.contentapi.ws/news?channel=us_domestic&limit=10&format=short&skip=",integer_to_list(SkipItems));
			
		"Politics" ->
			%Category = "Politics",
			string:concat("http://api.contentapi.ws/news?channel=us_politics&limit=10&format=short&skip=",integer_to_list(SkipItems));
			
		"Entertainment" ->
			%Category = "Entertainment",
			string:concat("http://api.contentapi.ws/news?channel=us_entertainment&limit=10&format=short&skip=",integer_to_list(SkipItems));
		
		"Markets" ->
			%Category = "Entertainment",
			string:concat("http://api.contentapi.ws/news?channel=us_markets&limit=10&format=short&skip=",integer_to_list(SkipItems));

		"Money" ->
			%Category = "Entertainment",
			string:concat("http://api.contentapi.ws/news?channel=us_money&limit=10&format=short&skip=",integer_to_list(SkipItems));
		_ ->

			%Category = "None",
			lager:info("#########################None")

	end,
	% io:format("more news ~p ~n ",[Url_more_news]),

	{ok, "200", _, Response} = ibrowse:send_req(Url_more_news,[],get,[],[]),
	ResponseParams = jsx:decode(list_to_binary(Response)),	
	ParamsAllNews = proplists:get_value(<<"articles">>, ResponseParams),


	 % for video display
	% Url = wildridgeclone_util:video_count(binary_to_list(<<"full_composite_article">>),binary_to_list(<<"1">>),binary_to_list(<<"2">>)),
	% {ok, "200", _, Response} = ibrowse:send_req(Url,[],get,[],[]),
	% Res = string:sub_string(Response, 1, string:len(Response) -1 ),	
	% ResponseParams = jsx:decode(list_to_binary(Res)),
	% [ResponseRows] = proplists:get_value(<<"rows">>, ResponseParams),
	% VideoParams = proplists:get_value(<<"value">>, ResponseRows),

	Url = "http://api.contentapi.ws/videos?channel=world_news&limit=1&skip=2&format=long",
	% io:format("movies url: ~p~n",[Url]),
	{ok, "200", _, Response_mlb} = ibrowse:send_req(Url,[],get,[],[]),
	ResponseParams_mlb = jsx:decode(list_to_binary(Response_mlb)),	
	[VideoParams] = proplists:get_value(<<"articles">>, ResponseParams_mlb),

	{ok, Body} = more_news_dtl:render([{<<"videoParam">>,VideoParams},{<<"news_category">>,Category},{<<"allnews">>,ParamsAllNews}]),
    {Body, Req, State}.


