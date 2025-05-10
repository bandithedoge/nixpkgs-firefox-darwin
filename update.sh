#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq
# shellcheck shell=bash

base_url="https://download-installer.cdn.mozilla.net/pub"

function generate_json_librewolf() {
  base_json_librewolf="$(curl -s https://gitlab.com/api/v4/projects/44042130/releases/)"
  url="$(echo $base_json_librewolf | jq -r '.[0].assets.links[].direct_asset_url' | grep .macos-$1-package.dmg$)"

  jq -n \
    --arg version "$(echo $base_json_librewolf | jq -r '.[0].tag_name')" \
    --arg url $url \
    --arg sha256 "$(curl -sL $url.sha256sum)" \
    '{version: $version, url: $url, sha256: $sha256}'
}

function generate_json_floorp() {
  base_json_floorp="$(curl -s https://api.github.com/repos/Floorp-Projects/Floorp/releases/latest)"
  url="$(echo $base_json_floorp | jq -r '.assets[].browser_download_url' | grep .floorp-macOS-*)"

  temp_file="/tmp/floorp-macOS-universal.dmg"
  curl -Ls -o $temp_file $url

  sha256="$(shasum -a 256 $temp_file | awk '{print $1}')"

  jq -n \
    --arg version "$(echo $base_json_floorp | jq -r '.tag_name')" \
    --arg url $url \
    --arg sha256 "$sha256" \
    '{version: $version, url: $url, sha256: $sha256}'
}

function generate_json_zen_browser() {
  base_json_zen_browser="$(get_github_json "zen-browser/desktop")"

  generate_json_github "$base_json_zen_browser" "zen.macos-*"
}

function get_github_json() {
  curl -s -H "Accept: application/vnd.github+json" "https://api.github.com/repos/$1/releases/latest"
}

function generate_json_github() {
  url="$(echo $1 | jq -r '.assets[].browser_download_url' | grep $2)"

  temp_file="$(mktemp)"
  curl -Ls -o $temp_file $url

  sha256="$(shasum -a 256 $temp_file | awk '{print $1}')"

  jq -n \
    --arg version "$(echo "$1" | jq -r '.tag_name')" \
    --arg url $url \
    --arg sha256 "$sha256" \
    '{version: $version, url: $url, sha256: $sha256}'
}

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
    firefox-nightly)
      jq -r '.FIREFOX_NIGHTLY'
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
  firefox-nightly)
    date=$(curl -s "$base_url/firefox/nightly/latest-mozilla-central/firefox-$(get_version "$1").en-US.mac.buildhub.json" | jq -r ".build.date")

    year=$(date -u -d $date +"%Y")
    month=$(date -u -d $date +"%m")
    formatted_date=$(date -u -d $date +"%Y-%m-%d-%H-%M-%S")

    echo "firefox/nightly/$year/$month/$formatted_date-mozilla-central"
    ;;
  esac
}

function get_url() {
  if [ "$1" != "firefox-nightly" ]; then
    echo "$base_url/$(get_path "$1")/mac/en-US/Firefox%20$(get_version "$1").dmg"
  else
    echo "$base_url/$(get_path "$1")/firefox-$(get_version "$1").en-US.mac.dmg"
  fi
}

function get_sha256() {
  if [ "$1" != "firefox-nightly" ]; then
    curl -s "$base_url/$(get_path "$1")/SHA256SUMS" |
      grep "mac/en-US/Firefox $(get_version "$1").dmg" |
      awk '{print $1}'
  else
    curl -s "$base_url/$(get_path "$1")/firefox-$(get_version "$1").en-US.mac.checksums" |
      grep "sha256.*\.dmg" |
      awk '{print $1}'
  fi
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
      "firefox-esr": $(generate_json "firefox-esr"),
      "firefox-nightly": $(generate_json "firefox-nightly"),
      "librewolf-arm64": $(generate_json_librewolf "arm64"),
      "librewolf-x86_64": $(generate_json_librewolf "x86_64"),
      "floorp-x86_64": $(generate_json_floorp "x86_64"),
      "zen-browser": $(generate_json_zen_browser)
    }
EOF
)

echo "$json" | jq . >sources.json