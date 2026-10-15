#!/bin/bash

set -u

log() {
	echo >&2 "$@";
}

fail() {
	echo >&2 "$@";
	exit 1;
}

click() {
	clickhouse client -h $CLICK_HOST --secure -d $CLICK_DB -u $CLICK_USER --password=$CLICK_PASS \
		"$@"
}

user_id() {
	local login=$1 res

	res="$(gh api users/$login)" || { log "user_id:gh $*";          return 1; }
	jq -r .id <<<"$res"          || { log "user_id:jq $* ==> $res"; return 1; }
}

repo_id() {
	local login=$1 repo=$2 res

	res="$(gh api repos/$login/$repo)" || { log "repo_id:gh $*";          return 1; }
	jq -r .id <<<"$res"                || { log "repo_id:jq $* ==> $res"; return 1; }
}

followers_do() {
	local login=$1 id req res

	id="$(user_id $login)" || return 1

	res="$(gh api --paginate users/$login/followers)" || { log "followers_do:gh $*"; return 1; }
	req="$(jq -c --arg id "$id" --arg login "$login" \
		'.[] | {id: $id, login: $login, f_id: .id, f_login: .login}' <<<"$res")" ||
							{ log "followers_do:jq $* ==> $res"; return 1; }

	click <<<"$req" --query \
		"INSERT INTO followers (id, login, f_id, f_login) SELECT id, login, f_id, f_login
			FROM input('id Int64, login String, f_id Int64, f_login String')
			FORMAT JSONEachRow" ||
		{ log "followers_do:ch $* ==> $res"; return 1; }
}

stars_do() {
	local table=$1 login=$2 repo=$3 id repo_id req res

	id="$(user_id $login)"            || return 1
	repo_id="$(repo_id $login $repo)" || return 1

	res="$(gh api --paginate repos/$login/$repo/stargazers )" || { log "stars_do:gh $*"; return 1; }
	req="$(jq -c --arg id "$id" --arg login "$login" --arg repo_id "$repo_id" --arg repo "$repo" \
		'.[] | {id: $id, login: $login, repo_id: $repo_id, repo: $repo, f_id: .id, f_login: .login}' <<<"$res")" ||
		{ log "stars_do:jq $* ==> $res"; return 1; }

	click <<<"$req" --query --arg table "$table" \
		"INSERT INTO \$table (id, login, repo_id, repo, f_id, f_login)
			SELECT id, login, repo_id, repo, f_id, f_login
			FROM input('id Int64, login String, repo_id Int64, repo String, f_id Int64, f_login String')
			FORMAT JSONEachRow" ||
		{ log "stars_do:ch $* ==> $res"; return 1; }
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

click --query "SELECT 1" >/dev/null && log "clickhouse is ok" || fail "clickhouse is ill, exiting"

[ "$#" -gt 0 ] && { "$@"; exit; }

followers nikandfor
followers nikandwork
followers slowlang
followers tlog-dev
followers txfail

followers filapro

followers korzhenevski
followers rndcenter

stars nikandfor batch
stars nikandfor bufq
stars nikandfor cbor
stars nikandfor cli
stars nikandfor cover
stars nikandfor dumpcy
stars nikandfor graceful
stars nikandfor hacked
stars nikandfor heap
stars nikandfor jq
stars nikandfor json2
stars nikandfor mqtt
stars nikandfor mux
stars nikandfor rawtls
stars nikandfor schema
stars nikandfor skip
stars nikandfor snmp
stars nikandfor socks5
stars nikandfor throttle
stars nikandfor vanity-go
stars nikandfor websocket

stars tlog-dev eazy
stars tlog-dev errors
stars tlog-dev loc
stars tlog-dev tlog

stars slowlang slow

stars filapro cad-recode
stars filapro oneformer3d
stars filapro unidet3d

stars col14m cadrille
