# Skills Upstream

Upstream mirror for 8 skill repos consolidated into a single sync point for [AgentHub](https://github.com/AiFeatures/agent-hub).

Each upstream is stored in `skills/<repo-name>/` and synced via `sync-upstreams.sh`.

## Sources

| Directory | Upstream | Skills |
|-----------|----------|--------|
| `sources/claude-code-skills/` | [levnikolaevich/claude-code-skills](https://github.com/levnikolaevich/claude-code-skills) | 128 |
| `sources/claude-scientific-skills/` | [K-Dense-AI/claude-scientific-skills](https://github.com/K-Dense-AI/claude-scientific-skills) | 178 |
| `sources/awesome-claude-skills/` | [ComposioHQ/awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills) | 859 |
| `sources/claude-code-skills-3/` | [daymade/claude-code-skills](https://github.com/daymade/claude-code-skills) | 43 |
| `sources/azure-skills/` | [microsoft/azure-skills](https://github.com/microsoft/azure-skills) | 24 |
| `sources/superpowers/` | [obra/superpowers](https://github.com/obra/superpowers) | 14 |
| `sources/ui-ux-pro-max-skill/` | [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | 7 |
| `sources/obsidian-skills/` | [kepano/obsidian-skills](https://github.com/kepano/obsidian-skills) | 5 |

## Usage

```bash
# Sync all upstreams (fetch + merge latest)
./sync-upstreams.sh

# Then import into AgentHub
cd ../agent-hub && make skills-sync
```

## How It Works

```
upstream repos (GitHub)
    |
    v  git fetch + merge
sources/<repo>/          <-- this repo (single mirror)
    |
    v  sync-external-skills.sh
agent-hub/copilot-skills/ <-- AgentHub (1479 skills)
    |
    v  symlink
~/.github/skills/        <-- active skills
```
