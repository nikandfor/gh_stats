#!/bin/bash

set -u

click() {
	clickhouse client -h $CLICK_HOST --secure -d $CLICK_DB -u $CLICK_USER --password=$CLICK_PASS \
		"$@"
}

user_id() {
	login=$1

	gh api users/$login | jq -r .id
}

repo_id() {
	login=$1
	repo=$2

	gh api repos/$login/$repo | jq -r .id
}

followers_do() {
	login=$1

	id=$(user_id $login)

	req=/tmp/save.json

	gh api --paginate users/$login/followers | \
		jq -c ".[] | {id: ${id}, login: \"${login}\", f_id: .id, f_login: .login}" \
		>$req

	jq -e '.' <$req >/dev/null && cat $req | \
		click --query "INSERT INTO followers (id, login, f_id, f_login) SELECT id, login, f_id, f_login FROM input('id Int64, login String, f_id Int64, f_login String') FORMAT JSONEachRow" || \
		true
}

stars_do() {
	table=$1
	login=$2
	repo=$3

	id=$(user_id $login)
	repo_id=$(repo_id $login $repo)

	req=/tmp/save.json

	gh api --paginate repos/$login/$repo/stargazers | \
		jq -c ".[] | {id: ${id}, login: \"${login}\", repo_id: ${repo_id}, repo: \"${repo}\", f_id: .id, f_login: .login}" \
		>$req

	jq -e '.' <$req >/dev/null && cat $req | \
		click --query "INSERT INTO ${table} (id, login, repo_id, repo, f_id, f_login) SELECT id, login, repo_id, repo, f_id, f_login FROM input('id Int64, login String, repo_id Int64, repo String, f_id Int64, f_login String') FORMAT JSONEachRow" || \
		true
}

followers() {
	followers_do "$@" && \
		echo "ok  : followers $1" || \
		echo "FAIL: followers $1"
}

stars() {
	stars_do stars "$@" && \
		echo "ok  : stars    $1/$2" || \
		echo "FAIL: stars    $1/$2"

	stars_do watchers "$@" && \
		echo "ok  : watchers $1/$2" || \
		echo "FAIL: watchers $1/$2"
}

echo Spinning up clickhouse...

click --query "SELECT 1" >/dev/null && echo clickhouse is ok || { echo clickhouse is ill, exiting; exit; }

followers nikandfor
followers tlog-dev
followers slowlang
followers txfail
followers nikandwork

followers filapro

followers korzhenevski
followers rndcenter

stars nikandfor batch
stars nikandfor json
stars nikandfor graceful
stars nikandfor throttle
stars nikandfor cli
stars nikandfor hacked
stars nikandfor heap
stars nikandfor socks5
stars nikandfor cover

stars tlog-dev tlog
stars tlog-dev eazy
stars tlog-dev errors
stars tlog-dev loc

stars slowlang slow

stars filapro oneformer3d
stars filapro unidet3d

