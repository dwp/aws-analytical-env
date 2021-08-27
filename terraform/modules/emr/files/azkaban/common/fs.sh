#!/usr/bin/env bash

fs::clear_directory() {
  local directory=${1:?Usage ${FUNCNAME[0]} directory}
  [[ -d "$directory" ]] && rm -rf "$directory"
  mkdir -p "$directory"
}
