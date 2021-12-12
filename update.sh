#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq
# shellcheck shell=bash

base_url="https://download-installer.cdn.mozilla.net/pub"

function get_version() {
	curl -s "https://product-details.mozilla.org/1.0/firefox_versions.json" |
		case $1 in
		firefox)
			jq -r '.LATEST_FIREFOX_VERSION'
			;;
		firefox-beta | firefox-devedition)
			jq -r '.LATEST_FIREFOX_DEVEL_VERSION'
			;;
		firefox-esr)
			jq -r '.FIREFOX_ESR'
			;;
		esac
}

function get_path() {
	case $1 in
	firefox | firefox-beta | firefox-esr)
		echo "firefox/releases/$(get_version "$1")"
		;;
	firefox-devedition)
		echo "devedition/releases/$(get_version "$1")"
		;;
	esac
}

function get_url() {
	echo "$base_url/$(get_path "$1")/mac/en-US/Firefox%20$(get_version "$1").dmg"
}

function get_sha256() {
	curl -s "$base_url/$(get_path "$1")/SHA256SUMS" |
		grep "mac/en-US/Firefox $(get_version "$1").dmg" |
		awk '{print $1}'
}

function generate_json() {
	# shellcheck disable=2086
	jq -n \
		--arg version "$(get_version $1)" \
		--arg url "$(get_url $1)" \
		--arg sha256 "$(get_sha256 $1)" \
		'{version: $version, url: $url, sha256: $sha256}'
}

json=$(
	cat <<EOF
    {
        "firefox": $(generate_json "firefox"),
        "firefox-beta": $(generate_json "firefox-beta"),
        "firefox-devedition": $(generate_json "firefox-devedition"),
        "firefox-esr": $(generate_json "firefox-esr")
    }
EOF
)

echo "$json" | jq . > sources.json
