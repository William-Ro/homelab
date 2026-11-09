# Decisions

Decision records for lasting architectural and operational choices in this
repo, with their rationale. The point is to stop a human or an agent from
re-litigating a settled question, or silently "fixing" something that was a
deliberate tradeoff.

Use [`template.md`](template.md) for new entries. Number sequentially; never
renumber or delete a past decision — mark it Superseded and link the
replacement instead.

| # | Title | Status |
| --- | --- | --- |
| [0001](0001-reject-policy-as-code-ci-tooling.md) | Reject policy-as-code CI tooling (conftest/kubeconform/flate) | Accepted |
| [0002](0002-accept-renovate-automerge-without-ci-gate.md) | Accept Renovate automerge without a CI gate | Accepted |

Not every change needs a record — only choices that trade something off, that
aren't obvious from the code/manifests alone, or that someone could plausibly
"undo" later without realizing it was intentional.
