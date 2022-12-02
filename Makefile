default: mix-format mix-credo mix-dialyzer mix-test gettext

mix-format:
	mix format

mix-credo:
	mix credo

mix-dialyzer:
	mix dialyzer --format dialyxir

mix-test:
	mix test

gettext:
	mix gettext.extract --merge

seed:
	mix run priv/repo/seeds.exs
