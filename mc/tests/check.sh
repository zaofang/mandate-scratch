#!/usr/bin/env bash
# Tests for bin/mandate-check. Each case copies template/ into a scratch repo, mutates it, and expects pass or fail.
set -uo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
check=$root/bin/mandate-check
export MANDATE_SOURCE=$root
failures=0

project() {
  dir=$(mktemp -d)
  cp -R "$root/template/." "$dir"
  cat >"$dir/.github/workflows/stubs.yml" <<'YML'
name: stubs
on: pull_request
jobs:
  mandate-gate:
    runs-on: ubuntu-latest
    steps: [{run: "true"}]
  ci:
    runs-on: ubuntu-latest
    steps: [{run: "true"}]
YML
  sed -i 's/^name: <project>$/name: demo/' "$dir/VISION.md"
  git -C "$dir" init -q && git -C "$dir" add -A && git -C "$dir" -c user.name=t -c user.email=t@t commit -qm base
}

adr() { printf -- '---\nid: %s\ntitle: t\nstatus: %s\ndate: 2026-11-12\n---\n## Context\n## Decision\n%s\n## Consequences\n## Alternatives\n' "$1" "$2" "$3" >"$dir/docs/adr/$1-t.md"; }

expect() { # expect pass|fail name [base]
  local want=$1 name=$2 got
  (cd "$dir" && bash "$check" ${3:+"$3"} >/dev/null 2>&1) && got=pass || got=fail
  if [[ $got == "$want" ]]; then echo "ok   $name"; else echo "FAIL $name: expected $want, got $got"; failures=$((failures + 1)); fi
  rm -rf "$dir"
}

project; expect pass "template passes"
project; rm "$dir/ROADMAP.md"; expect fail "missing required file"
project; sed -i 's/^status: inception$/status: sleeping/' "$dir/VISION.md"; expect fail "invalid VISION status"
project; sed -i 's/^profile: tooling$/profile: web/' "$dir/VISION.md"; expect fail "invalid profile"
project; adr 0001 accepted a; adr 0002 accepted b; expect pass "contiguous ADRs"
project; adr 0001 accepted a; adr 0003 accepted b; expect fail "gap in ADR numbers"
project; adr 0001 proposed a; expect fail "invalid ADR status"
project; adr 0001 "superseded by 0002" a; adr 0002 accepted b; expect pass "superseded ADR"
project; adr 0001 accepted a; git -C "$dir" add -A; git -C "$dir" -c user.name=t -c user.email=t@t commit -qm adr; adr 0001 accepted changed; expect fail "edited Decision" HEAD
project; adr 0001 accepted a; git -C "$dir" add -A; git -C "$dir" -c user.name=t -c user.email=t@t commit -qm adr; adr 0001 "superseded by 0002" a; adr 0002 accepted b; expect pass "supersession keeps Decision" HEAD
project; printf '@AGENTS.md\n' >"$dir/CLAUDE.md"; expect fail "CLAUDE.md imports"
project; echo extra >>"$dir/.mandate/agents.md"; expect fail "contract drift"
project; rm "$dir/.github/workflows/stubs.yml"; expect fail "required check without job"
project; sed -i 's/^on: pull_request$/on:\n  pull_request:\n    paths: [src\/**]/' "$dir/.github/workflows/stubs.yml"; expect fail "required check path-filtered"

exit $((failures > 0))
