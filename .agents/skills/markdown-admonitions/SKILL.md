---
name: markdown-admonitions
description: "Convert Skillable Markdown admonitions to GitHub-standard alert syntax. USE FOR: fixing admonitions, callouts, alerts, notes, warnings, tips in Markdown files for GitHub repos. Trigger phrases include 'fix admonitions', 'standardize callouts', 'convert alerts to GitHub format', 'non-standard admonitions'. DO NOT USE FOR: general Markdown formatting, non-GitHub platforms (Docusaurus, MkDocs, Obsidian)."
---

# GitHub Markdown Admonition Standardization

## GitHub-Standard Admonitions

GitHub supports exactly five admonition types. No others render correctly.

| Type      | Syntax           | Use for                                           |
| --------- | ---------------- | ------------------------------------------------- |
| NOTE      | `> [!NOTE]`      | Supplemental information the reader should know   |
| TIP       | `> [!TIP]`       | Helpful advice to make the reader more successful |
| IMPORTANT | `> [!IMPORTANT]` | Crucial information for success                   |
| WARNING   | `> [!WARNING]`   | Urgent info needing immediate attention           |
| CAUTION   | `> [!CAUTION]`   | Negative potential consequences of an action      |

Reference: https://github.com/orgs/community/discussions/16925

## Required Format

The admonition tag **must** be on its own line, uppercase, with content on the **next** line:

```markdown
> [!NOTE]
> Content goes on a separate line.
```

**Never** put content inline with the tag:

```markdown
> [!NOTE] This is wrong and will not render.
```

## Procedure

### Step 1: Search for all admonitions

Search all `*.md` files for admonition-like patterns:

```
\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION|DANGER|INFO|ERROR|BUG|EXAMPLE|QUOTE|ABSTRACT|SUCCESS|QUESTION|FAILURE|TODO|HINT|ATTENTION|NOTICE|ALERT|CRITICAL|HELP|KNOWLEDGE)\]
```

Also search for legacy bold-text syntax and variant bracket patterns:

```
> \*\*(Note|Warning|Tip|Important|Caution)\*\*
> \[\+
```

### Step 2: Classify each match

- **Already standard** (`[!NOTE]`, `[!TIP]`, `[!IMPORTANT]`, `[!WARNING]`, `[!CAUTION]` uppercase, content on next line) → skip
- **Non-standard type** → map to the closest standard type (see mapping below)
- **Inline content** (tag and text on same line) → split to two lines
- **Multi-line with embedded code blocks** → convert to collapsible section (see Step 4)

### Step 3: Apply type mapping

| Non-standard                                                                          | Maps to                      |
| ------------------------------------------------------------------------------------- | ---------------------------- |
| `[!hint]`, `[!help]`, `[!info]`, `[!abstract]`, `[!summary]`, `[!question]`, `[!faq]` | `[!TIP]`                     |
| `[!note]` (lowercase), `[!knowledge]`, `[!example]`, `[!quote]`, `[!cite]`, `[!todo]` | `[!NOTE]`                    |
| `[!alert]`, `[!attention]`, `[!notice]`, `[!danger]`, `[!error]`, `[!critical]`       | `[!WARNING]`                 |
| `[!failure]`, `[!fail]`, `[!missing]`, `[!bug]`                                       | `[!CAUTION]`                 |
| `[!success]`, `[!check]`, `[!done]`                                                   | `[!IMPORTANT]`               |
| `> **Note**` (legacy bold syntax)                                                     | `[!NOTE]`                    |
| `> **Warning**` (legacy bold syntax)                                                  | `[!WARNING]`                 |
| `> [+TYPE]` (collapsible variant)                                                     | Map `TYPE` using rules above |

Also fix lowercase standard types (e.g., `[!note]` → `[!NOTE]`).

### Step 4: Handle multi-line admonitions

If an admonition contains **embedded code blocks** (triple backticks inside `>` blockquote lines), convert it to a **collapsible `<details>` section** with the admonition as the summary:

**Before:**

````markdown
> [!NOTE]
> Here is some context.
> You could also run this:
>
> ```bash
> kubectl get pods
> ```
>
> Additional explanation here.
````

**After:**

````markdown
<details>
<summary>

> [!NOTE]
> Here is some context.

</summary>

You could also run this:

```bash
kubectl get pods
```
````

Additional explanation here.

</details>
```

Rules for the conversion:

- The `<summary>` block contains the admonition tag and a short description (the first sentence or paragraph)
- The `<details>` body contains the rest of the content **without** `>` blockquote prefixes
- Code blocks inside `<details>` use normal Markdown (no `>` prefix)
- Blank lines are required after `<summary>` and before `</details>`

### Step 5: Validate

After all edits, search again to confirm no non-standard admonitions remain:

```
\[!((?!NOTE|TIP|IMPORTANT|WARNING|CAUTION\b)[A-Za-z]+)\]
```

Also verify no inline content patterns remain (tag and text on same line).

## Gotchas

- GitHub admonition types are **case-sensitive** — `[!NOTE]` works, `[!note]` does not render as a styled alert
- Content **must** start on the line after `[!TYPE]`, not on the same line
- Admonitions **cannot be nested** inside other elements on GitHub (lists, tables, other blockquotes)
- The legacy `> **Note**` bold syntax is no longer supported by GitHub — always use `> [!NOTE]`
- Multi-line admonitions with embedded code blocks don't render well on GitHub because the `>` prefix breaks fenced code formatting — use collapsible `<details>` sections instead
