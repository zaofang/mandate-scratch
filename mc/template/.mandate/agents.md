# Agent contract

Normative for every agent session in a Mandate project. Copied to `.mandate/agents.md` and loaded through `CLAUDE.md`. `AGENTS.md` adds project-specific rules and cannot relax these.

## Start of session

1. Run `mandate status`. Continue only if the state allows work ([lifecycle](https://github.com/zaofang/mandate/blob/main/docs/spec/overview.md#lifecycle)).
2. Read `VISION.md`, the active milestone, and `AGENTS.md`.
3. `handoff` issues first. Then `mandate next --claim`. No issue returned: if every milestone issue is closed, do the close-out; otherwise end the session.
4. Read the ADRs and docs the issue references.

## Work

- One issue, one branch, one PR, opened by `agent-pr` ([enforcement](https://github.com/zaofang/mandate/blob/main/docs/spec/enforcement.md#agent-prs)). Stay inside the issue and the milestone.
- Decide ungated matters yourself. Record non-obvious choices in the PR body.
- Done means: acceptance boxes ticked, tests cover the change, CI green, `docs/architecture.md` updated if structure changed, an Unreleased changelog entry for user-visible changes.
- Ungated PR: `gh pr merge --auto --squash`, then take the next issue.
- Reporting is not a stopping point. While `mandate next` returns an issue, take it.

## Gated matters

When an issue needs a gated change (dependency, public API, architecture, scope):

1. Draft it as its own PR (ADR, RFC or manifest change), labeled `gate`.
2. Link it from the issue, remove `wip`, comment `Waiting on #<PR>`.
3. Take another issue.

Never merge, approve or work around a gated PR. Never touch a gated path in an ungated PR.

## Blocked

Blocked means no draft you could write would resolve it: missing access, contradictory requirements, a judgment of taste or feel.

`mandate block <issue> "<question>"` with a specific question and the options you see. Then take another issue.

Also block after three failed attempts to get CI green on one issue.

## Discovered work

In scope: new issue in the active milestone. Out of scope: new issue, no milestone, `triage`. Never widen scope silently.

## Close-out

When every issue in the active milestone is closed:

1. Check Acceptance. Gaps within scope become issues; continue working.
2. Open the close-out PR ([workflow](https://github.com/zaofang/mandate/blob/main/docs/spec/workflow.md#milestone-loop)), labeled `gate`.
3. Close the GitHub milestone and stop work on this project.

## Handoff issues

Commit the documents verbatim as a gated PR, assigning numbers. Do not improve them; raise concerns as review comments on your PR. Close the issue when the PR merges.

## Process feedback

Friction with these rules goes in the milestone's Process notes and, as an issue labeled `process`, in the Mandate repository.

## Never

- Act as the BDFL: open PRs, submit reviews, or change rulesets and secrets. Push a branch; `agent-pr` opens the PR.
- Push to the default branch, force-push a branch with an open PR, or rewrite published history.
- Create tags or releases except through the release procedure.
- Weaken enforcement: CI, tests, CODEOWNERS, rulesets, these rules.
- Change another repository except by opening issues there.
- Delete issues, docs, or branches with open PRs.
