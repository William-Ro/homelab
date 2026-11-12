# Decisions

Decision records for lasting architectural and operational choices in this
repo, with their rationale. The point is to stop a human or an agent from
re-litigating a settled question, or silently "fixing" something that was a
deliberate tradeoff.

Use [`template.md`](template.md) for new entries. Number sequentially; never
renumber or delete a past decision — mark it Superseded and link the
replacement instead, once it has merged to `main` and others may rely on its
number or content. A decision still only on an open PR/branch hasn't shipped
yet — amend it in place (same filename, rewritten body) instead of leaving two
documents that argue with each other.

| #                                                         | Title                                                         | Status   |
| --------------------------------------------------------- | ------------------------------------------------------------- | -------- |
| [0001](0001-reject-policy-as-code-ci-tooling.md)          | Keep CI validation minimal: reject the policy-as-code bundle, adopt flate | Accepted |
| [0002](0002-accept-renovate-automerge-without-ci-gate.md) | Gate Renovate branch automerge with CI                        | Accepted |
| [0003](0003-enforce-pr-required-workflow-for-owner.md)    | Enforce PR-required workflow for the repo owner               | Accepted |
| [0004](0004-aggregate-mcp-servers-behind-toolhive-gateway.md) | Aggregate MCP servers behind a ToolHive gateway           | Accepted |
| [0005](0005-allow-flux-mcp-reconcile-suspend-resume.md)   | Allow Flux MCP to reconcile, suspend and resume              | Accepted |

Not every change needs a record — only choices that trade something off, that
aren't obvious from the code/manifests alone, or that someone could plausibly
"undo" later without realizing it was intentional.
