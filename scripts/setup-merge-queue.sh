#!/usr/bin/env bash
#
# setup-merge-queue.sh — configure GitHub branch protection for the Trunk Merge Queue.
#
# Run this AFTER the Trunk GitHub App is installed on the repo. It creates the two
# rulesets Trunk recommends and enables squash merges, so all merges to the default
# branch flow through the queue. Idempotent: re-running updates the existing rulesets
# in place (matched by name) instead of duplicating them.
#
#   Ruleset "merge-queue-branch-update"  — Restrict updates; the trunk-io app bypasses
#                                          it as Exempt so the queue can push merges.
#   Ruleset "merge-queue-mergeability"   — Require a PR + required status checks;
#                                          Trunk is intentionally NOT on its bypass list.
#
# See https://docs.trunk.io/merge-queue/getting-started/configure-branch-protection
#
# Requirements:
#   - gh CLI, authenticated with admin rights on the repo (`gh auth login`)
#   - the Trunk GitHub App ("trunk-io") already installed on the repo
#
# Usage:
#   scripts/setup-merge-queue.sh                 # configures the current repo
#   scripts/setup-merge-queue.sh owner/repo      # configures a specific repo
#   TRUNK_APP_ID=12345 scripts/setup-merge-queue.sh owner/repo   # skip app-id discovery
#
set -euo pipefail

REPO="${1:-${REPO:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}}"
echo "Configuring Trunk Merge Queue branch protection for: ${REPO}"

# --- 1. Enable squash merges (required by the Trunk queue) ------------------
echo "→ Enabling squash merges…"
gh api "repos/${REPO}" -X PATCH -F allow_squash_merge=true >/dev/null

# --- 2. Resolve the Trunk GitHub App id -------------------------------------
# The bypass actor in ruleset #1 is the trunk-io app's integration id. Look it up by
# slug via /apps/{slug} — this works with a normal gh token. (/user/installations
# does NOT: it needs a GitHub-App user-to-server token and returns 403 otherwise.)
TRUNK_APP_SLUG="${TRUNK_APP_SLUG:-trunk-io}"
if [[ -z "${TRUNK_APP_ID:-}" ]]; then
  echo "→ Resolving the ${TRUNK_APP_SLUG} GitHub App id…"
  TRUNK_APP_ID="$(gh api "/apps/${TRUNK_APP_SLUG}" --jq '.id' 2>/dev/null || true)"
fi
# Validate before use: a failed lookup must never get injected into the ruleset body.
if ! [[ "${TRUNK_APP_ID:-}" =~ ^[0-9]+$ ]]; then
  cat >&2 <<EOF
ERROR: could not resolve the '${TRUNK_APP_SLUG}' GitHub App id (got: '${TRUNK_APP_ID:-}').
  Make sure the Trunk GitHub App is installed on ${REPO}, then re-run — or pass the
  id explicitly:  TRUNK_APP_ID=<id> $0 ${REPO}
  Find it with:  gh api /apps/${TRUNK_APP_SLUG} --jq .id
EOF
  exit 1
fi
echo "  ${TRUNK_APP_SLUG} app id: ${TRUNK_APP_ID}"

# --- helper: create-or-update a ruleset by name -----------------------------
upsert_ruleset() {
  local name="$1" body="$2" id
  id="$(gh api "repos/${REPO}/rulesets" \
    --jq ".[] | select(.name==\"${name}\") | .id" 2>/dev/null | head -n1 || true)"
  if [[ -n "${id}" ]]; then
    echo "→ Updating ruleset '${name}' (id ${id})…"
    printf '%s' "${body}" | gh api "repos/${REPO}/rulesets/${id}" -X PUT --input - >/dev/null
  else
    echo "→ Creating ruleset '${name}'…"
    printf '%s' "${body}" | gh api "repos/${REPO}/rulesets" -X POST --input - >/dev/null
  fi
}

# --- 3. Ruleset #1: Restrict updates; trunk-io bypasses as Exempt -----------
# "Always" bypass does NOT cover branch updates from a GitHub App — must be "exempt".
upsert_ruleset "merge-queue-branch-update" "$(cat <<EOF
{
  "name": "merge-queue-branch-update",
  "target": "branch",
  "enforcement": "active",
  "conditions": { "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] } },
  "rules": [
    { "type": "update", "parameters": { "update_allows_fetch_and_merge": false } }
  ],
  "bypass_actors": [
    { "actor_type": "Integration", "actor_id": ${TRUNK_APP_ID}, "bypass_mode": "exempt" }
  ]
}
EOF
)"

# --- 4. Ruleset #2: Mergeability gate; Trunk does NOT bypass ----------------
# Contexts must match the CI job names in .github/workflows (Unit Tests / E2E Tests).
# required_approving_review_count: 0 lets the demo's automated PRs merge without a human
# review. strict_required_status_checks_policy: false disables "require branches to be up
# to date" — it conflicts with the queue and otherwise leaves PRs stuck in "Queued".
upsert_ruleset "merge-queue-mergeability" "$(cat <<'EOF'
{
  "name": "merge-queue-mergeability",
  "target": "branch",
  "enforcement": "active",
  "conditions": { "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] } },
  "rules": [
    { "type": "pull_request", "parameters": {
        "required_approving_review_count": 0,
        "dismiss_stale_reviews_on_push": false,
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "required_review_thread_resolution": false,
        "allowed_merge_methods": ["squash"]
    } },
    { "type": "required_status_checks", "parameters": {
        "strict_required_status_checks_policy": false,
        "do_not_enforce_on_create": false,
        "required_status_checks": [
          { "context": "Unit Tests" },
          { "context": "E2E Tests" }
        ]
    } }
  ],
  "bypass_actors": []
}
EOF
)"

echo
echo "✓ Branch protection configured for ${REPO}."
echo "  Next: create a queue for this repo in Trunk (Merge Queue → add repo, target 'main'),"
echo "  then add PRs with the '/trunk merge' comment (or: npm run open-prs -- --count N --queue)."
