default: credo dialyzer

credo:
	mix credo

dialyzer:
	mix dialyzer

gettext:
	mix gettext.extract --merge && mix gettext.extract --merge --locale=ru

prod-console-heroku:
	heroku run "DB_POOL_SIZE=2 ./bin/cat_on_duty start_iex"
