# Claude Skills

> This is a personal side project — built evenings and weekends, around a full-time job.
> No support, no roadmap commitments, no guarantees.

Agent skills for disciplined software delivery — one that builds whole projects unattended, one that governs how the agent works on everything else.

Both follow the [Agent Skills](https://agentskills.io) open standard: plain markdown, no vendor lock-in, portable to any agent that can read local files.

---

## The skills

### [weekend-project](plugins/weekend-project/) — autonomous project builder

Describe what you want in one line. It interviews you, plans the build as a series of small PRs with explicit acceptance criteria, shows you a token estimate, and — once you approve — builds each PR test-first, reviews its own work as an adversarial QA engineer, fixes what it finds, runs a production gate, and merges to `develop-ai`.

You approve once, then step away.

→ [README](plugins/weekend-project/README.md) · [How it works, with a real run](plugins/weekend-project/HOW-IT-WORKS.md)

### [code-better](plugins/code-better/) — behavioural modes

Forty-two one-word commands that set how the agent works and hold it for the session. `cb-read-only` so it looks without touching. `cb-minimal` so a small fix stays small. `cb-careful` before the migration. They stack, and safety modes always beat action modes.

→ [README](plugins/code-better/README.md)

**They're independent.** Use either on its own. `weekend-project` gets slightly richer when `code-better` is installed alongside it, but never depends on it.

---

## Status

`weekend-project` is at 1.0.0 and `code-better` is at 1.1.0, both installable. What that means in practice:

- The **per-PR loop** — build, QA rounds, fix rounds, merge gate — is what the [worked example](plugins/weekend-project/HOW-IT-WORKS.md) documents, on a real project, with the findings and the token cost it produced.
- The **plan queue** and the **worktree state handling** are new in this release and have not been run end to end yet.
- `code-better` has been in daily use, but this is its first packaged release.

Rough edges are likely in the newer parts. [Discussions](https://github.com/maneja81/claude-skills/discussions) is the place for them.

See [CHANGELOG.md](CHANGELOG.md) for what shipped, and [DECISIONS.md](DECISIONS.md) for why the non-obvious parts work the way they do.

---

## Installation

### Plugin marketplace (recommended)

Add the marketplace once, then install whichever you want:

```
/plugin marketplace add maneja81/claude-skills

/plugin install weekend-project@maneja81-skills
/plugin install code-better@maneja81-skills

/reload-plugins
```

### Install script

```bash
# both skills, personal scope (~/.claude/skills/)
curl -fsSL https://raw.githubusercontent.com/maneja81/claude-skills/main/install.sh | bash
```

From a clone, for more control:

```bash
git clone https://github.com/maneja81/claude-skills.git
cd claude-skills

./install.sh                            # both, personal
./install.sh weekend-project            # just one
./install.sh --project code-better      # into ./.claude/skills/ of the current project
./install.sh --uninstall                # remove both
./install.sh --help
```

### Manual copy

Each skill is a self-contained directory. Copy it wherever your agent looks for skills — the directory name must stay as-is, because for personal and project skills the directory name *is* the command name.

```bash
cp -R plugins/weekend-project/skills/weekend-project ~/.claude/skills/
cp -R plugins/code-better/skills/code-better ~/.claude/skills/
```

| Scope | Path |
|---|---|
| Personal | `~/.claude/skills/<name>/SKILL.md` |
| Project | `.claude/skills/<name>/SKILL.md` |
| Plugin | handled by the marketplace install above |

### Claude Desktop / claude.ai

Download a bundle from [`bundles/`](bundles/) and upload it under **Settings → Capabilities → Skills** (or **Customize → Skills**) via **+ → Create skill → Upload a skill**.

- [`bundles/weekend-project.zip`](bundles/weekend-project.zip)
- [`bundles/code-better.zip`](bundles/code-better.zip)

Uploaded skills are private to your account. On Team or Enterprise, use the org provisioning flow to share one.

---

## Repository layout

```
.claude-plugin/
  marketplace.json              catalogue listing both plugins
plugins/
  weekend-project/
    .claude-plugin/plugin.json
    skills/weekend-project/     the skill itself
    README.md · HOW-IT-WORKS.md · LICENSE
  code-better/
    .claude-plugin/plugin.json
    skills/code-better/         the skill itself
    README.md · LICENSE
bundles/                        uploadable zips for Claude Desktop / claude.ai
install.sh                      installer for both skills
```

One marketplace, two independently versioned plugins. Releases are tagged `<plugin-name>--v<version>`, so each skill moves on its own schedule.

---

## Contributing

[Discussions](https://github.com/maneja81/claude-skills/discussions) is the place — especially for real run reports from `weekend-project`. If you build something with it, the useful thing to share is what the QA pass caught and what it missed. PRs are welcome too; replies land when they land.

Edit the skill under `plugins/<name>/skills/<name>/` — that's the source of truth — then rebuild its bundle:

```bash
cd plugins/weekend-project/skills && zip -r ../../../bundles/weekend-project.zip weekend-project -x '*.DS_Store'
cd plugins/code-better/skills    && zip -r ../../../bundles/code-better.zip    code-better    -x '*.DS_Store'
```

Keep each `SKILL.md` lean. New procedural detail belongs in a file that loads on demand, not in the always-resident entry point.

---

## License

[MIT](LICENSE) © Mohit Aneja ([@maneja81](https://github.com/maneja81))
