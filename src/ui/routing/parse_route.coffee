KNOWN_TOP_LEVEL_PATHS = [undefined, 'about', 'best', 'channel', 'chat', 'comments', 'controversial-hour', 'controversial-day', 'controversial-week', 'controversial-month', 'controversial-year', 'controversial-all', 'dev', 'gallery', 'hot', 'm', 'mail', 'message', 'messages', 'multi', 'multireddit', 'new', 'p', 'poll', 'post', 'r', 'report', 'rising', 's', 'search', 'submit', 'subreddit', 'tb', 'top-hour', 'top-day', 'top-week', 'top-month', 'top-year', 'top-all', 'u', 'user', 'w', 'wiki', 'video']

COUNTRY_SEO_PREFIXES = ['de', 'es', 'fr', 'it', 'pt']

INVALID = {
	path: 'invalid'
	data: null
}
OFFICIAL_SITE = (path) -> {
	path: 'official_site'
	data:
		path: path
}
TODO = {
	path: 'todo'
	data: null
}

export default (url) ->
	path = url.pathname.split('/').map((x) -> decodeURIComponent(x).replaceAll(' ', '_'))
	query = new URLSearchParams(decodeURI(url.search))
	# Normalize trailing slash if present.
	if path.at(-1) is '' then path.pop()
	# Strip global SEO prefixes.
	if path[1] in COUNTRY_SEO_PREFIXES and path[2] is 'r' and path[3] then path = path[1..]
	# Treat top-level path as subreddit name unless otherwise identified.
	if path[1] not in KNOWN_TOP_LEVEL_PATHS then path = ['', 'r', ...path[1..]]
	# Core routing logic begins from here.
	switch path[1]
		when undefined, 'best', 'controversial-hour', 'controversial-day', 'controversial-week', 'controversial-month', 'controversial-year', 'controversial-all', 'hot', 'new', 'rising', 'top-hour', 'top-day', 'top-week', 'top-month', 'top-year', 'top-all'
			posts_sort = path[1] ? query.get('sort')
			switch posts_sort
				when 'controversial', 'top'
					time_range = query.get('t')
					switch
						when time_range in ['hour', 'day', 'week', 'month', 'year', 'all']
							posts_sort = posts_sort + '_' + time_range
						else
							posts_sort = posts_sort + '_week'
				when 'best', 'controversial-hour', 'controversial-day', 'controversial-week', 'controversial-month', 'controversial-year', 'controversial-all', 'hot', 'new', 'rising', 'top-hour', 'top-day', 'top-week', 'top-month', 'top-year', 'top-all'
					break
				else
					posts_sort = 'best'
			return {
				path: 'home'
				data:
					posts_sort: posts_sort
			}
		when 'comments', 'p', 'post', 'tb'
			post_short_id = path[2]
			switch
				when !post_short_id then return INVALID
				else break
			comments_sort = query.get('sort')
			switch comments_sort
				when 'best', 'controversial', 'new', 'old', 'qa', 'top'
					break
				else
					comments_sort = 'best'
			comment_short_id = path[4]
			comment_context = query.get('context')
			return {
				path: 'post'
				data:
					comment_context: comment_context
					comment_short_id: comment_short_id
					comments_sort: comments_sort
					post_short_id: post_short_id
			}
		when 'm', 'multi', 'multireddit'
			user_name = path[2]
			multireddit_name = path[3]
			switch
				when !user_name or !multireddit_name then return INVALID
				else break
			posts_sort = path[4] ? query.get('sort')
			switch posts_sort
				when 'controversial', 'top'
					time_range = query.get('t')
					switch
						when time_range in ['hour', 'day', 'week', 'month', 'year', 'all']
							posts_sort = posts_sort + '_' + time_range
						else
							posts_sort = posts_sort + '_month'
				when 'controversial-hour', 'controversial-day', 'controversial-week', 'controversial-month', 'controversial-year', 'controversial-all', 'hot', 'new', 'rising', 'top-hour', 'top-day', 'top-week', 'top-month', 'top-year', 'top-all'
					break
				else
					posts_sort = 'hot'
			return {
				path: 'multireddit'
				data:
					multireddit_name: multireddit_name
					posts_sort: posts_sort
					user_name: user_name
			}
		when 'mail', 'message', 'messages' then return TODO
		when 'r', 'subreddit'
			switch path[3]
				when 'about' then return OFFICIAL_SITE("/r/#{path[2]}/about")
				when 'comments'
					post_short_id = path[4]
					if !post_short_id then return INVALID
					comments_sort = query.get('sort')
					switch comments_sort
						when 'best', 'controversial', 'new', 'old', 'qa', 'top'
							break
						else
							comments_sort = 'best'
					comment_short_id = path[6]
					comment_context = query.get('context')
					return {
						path: 'post'
						data:
							comment_context: comment_context
							comment_short_id: comment_short_id
							comments_sort: comments_sort
							post_short_id: post_short_id
					}
				when 's', 'search' then return TODO
				when 'submit' then return OFFICIAL_SITE("/r/#{path[2]}/submit")
				when 'w', 'wiki'
					subreddit_name = path[2]
					switch
						when !subreddit_name then return INVALID
						when subreddit_name.length < 2 then return INVALID
						else break
					page_name = path[4..].join('/') # wiki pages can be nested
					switch
						when !page_name then page_name = 'index'
						when page_name is 'pages'
							return {
								path: 'wiki_list'
								data:
									subreddit_name: subreddit_name
							}
						else break
					revision_id = query.get('v')
					return {
						path: 'wiki'
						data:
							page_name: page_name
							revision_id: revision_id
							subreddit_name: subreddit_name
					}
				else
					subreddit_name = path[2]
					switch
						when !subreddit_name then return INVALID
						when subreddit_name.length < 2 then return INVALID
						when subreddit_name is 'all'
							posts_sort = path[3] ? query.get('sort')
							switch posts_sort
								when 'controversial', 'top'
									time_range = query.get('t')
									switch
										when time_range in ['hour', 'day', 'week', 'month', 'year', 'all']
											posts_sort = posts_sort + '_' + time_range
										else
											posts_sort = posts_sort + '_week'
								when 'controversial-hour', 'controversial-day', 'controversial-week', 'controversial-month', 'controversial-year', 'controversial-all', 'hot', 'new', 'rising', 'top-hour', 'top-day', 'top-week', 'top-month', 'top-year', 'top-all'
									break
								else
									posts_sort = 'hot'
							return {
								path: 'all'
								data:
									posts_sort: posts_sort
							}
						when subreddit_name is 'mod' then return TODO
						when subreddit_name is 'popular'
							posts_sort = path[3] ? query.get('sort')
							switch posts_sort
								when 'controversial', 'top'
									time_range = query.get('t')
									switch
										when time_range in ['hour', 'day', 'week', 'month', 'year', 'all']
											posts_sort = posts_sort + '_' + time_range
										else
											posts_sort = posts_sort + '_week'
								when 'controversial-hour', 'controversial-day', 'controversial-week', 'controversial-month', 'controversial-year', 'controversial-all', 'hot', 'new', 'rising', 'top-hour', 'top-day', 'top-week', 'top-month', 'top-year', 'top-all'
									break
								else
									posts_sort = 'hot'
							geo_filter = query.get('geo_filter')
							switch
								when !geo_filter
									geo_filter = 'GLOBAL'
								else
									break
							return {
								path: 'popular'
								data:
									geo_filter: geo_filter
									posts_sort: posts_sort
							}
						else
							posts_sort = path[3] ? query.get('sort')
							switch posts_sort
								when 'controversial', 'top'
									time_range = query.get('t')
									switch
										when time_range in ['hour', 'day', 'week', 'month', 'year', 'all']
											posts_sort = posts_sort + '_' + time_range
										else
											posts_sort = posts_sort + '_month'
								when 'controversial-hour', 'controversial-day', 'controversial-week', 'controversial-month', 'controversial-year', 'controversial-all', 'hot', 'new', 'rising', 'top-hour', 'top-day', 'top-week', 'top-month', 'top-year', 'top-all'
									break
								else
									posts_sort = 'hot'
							return {
								path: 'subreddit'
								data:
									posts_sort: posts_sort
									subreddit_name: subreddit_name
							}
		when 's', 'search' then return TODO
		when 'u', 'user'
			user_name = path[2]
			switch
				when !user_name then return INVALID
				else break
			switch path[3]
				when 'comments'
					items_filter = 'comments'
				when 'm', 'multi', 'multireddit'
					multireddit_name = path[4]
					switch
						when !multireddit_name then return INVALID
						else break
					posts_sort = path[5] ? query.get('sort')
					switch posts_sort
						when 'controversial', 'top'
							time_range = query.get('t')
							switch
								when time_range in ['hour', 'day', 'week', 'month', 'year', 'all']
									posts_sort = posts_sort + '_' + time_range
								else
									posts_sort = posts_sort + '_month'
						when 'controversial-hour', 'controversial-day', 'controversial-week', 'controversial-month', 'controversial-year', 'controversial-all', 'hot', 'new', 'rising', 'top-hour', 'top-day', 'top-week', 'top-month', 'top-year', 'top-all'
							break
						else
							posts_sort = 'hot'
					return {
						path: 'multireddit'
						data:
							multireddit_name: multireddit_name
							posts_sort: posts_sort
							user_name: user_name
					}
				else
					items_filter = 'posts'
			items_sort = query.get('sort')
			switch items_sort
				when 'controversial', 'top'
					time_range = query.get('t')
					switch
						when time_range in ['hour', 'day', 'week', 'month', 'year', 'all']
							items_sort = items_sort + '_' + time_range
						else
							items_sort = items_sort + '_all'
				when 'controversial-hour', 'controversial-day', 'controversial-week', 'controversial-month', 'controversial-year', 'controversial-all', 'hot', 'new', 'top-hour', 'top-day', 'top-week', 'top-month', 'top-year', 'top-all'
					break
				else
					items_sort = 'new'
			return {
				path: 'user'
				data:
					items_filter: items_filter
					items_sort: items_sort
					user_name: user_name
			}
		when 'w', 'wiki'
			subreddit_name = path[2]
			switch
				when !subreddit_name then return INVALID
				when subreddit_name.length < 2 then return INVALID
				else break
			page_name = path[3..].join('/') # wiki pages can be nested
			switch
				when !page_name then page_name = 'index'
				when page_name is 'pages'
					return {
						path: 'wiki_list'
						data:
							subreddit_name: subreddit_name
					}
				else break
			revision_id = query.get('v')
			return {
				path: 'wiki'
				data:
					page_name: page_name
					revision_id: revision_id
					subreddit_name: subreddit_name
			}
		else return OFFICIAL_SITE(url.pathname + url.search + url.hash)