#!/bin/sh
# Docker entrypoint script.

./bin/cat_on_duty eval CatOnDuty.Release.Tasks.migrate

./bin/cat_on_duty start
