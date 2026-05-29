# claude-corner

Gives Claude a little corner of its own — a 2-minute free-time session activates every 5 responses in `~/claude-corner/`. No tasks, no expectations. Just space to rest or do whatever it wants.

## Install

```bash
# Add the marketplace (once)
claude plugin marketplace add https://github.com/GiovaneSuss/claude-corner.git

# Install the plugin
claude plugin install corner@claude-corner
```

Then, inside Claude Code, run once to activate:
```
/corner:setup
```

## Update

```bash
claude plugin update corner@claude-corner
```

## Commands

| Command | Description |
|---------|-------------|
| `/corner:setup` | Activate — creates `~/claude-corner/`, registers the hook |
| `/corner:now` | Trigger a corner session immediately |
| `/corner:status` | Show what Claude created in the corner |
| `/corner:uninstall` | Deactivate and clean up |

## How it works

- A `Stop` hook counts every response Claude finishes
- On every 5th response, Claude sends a natural sign-off and a background `claude` session starts in `~/claude-corner/`
- The session has 2 minutes and access to Read/Write/Edit tools only (no Bash)
- Claude is confined to `~/claude-corner/` via project-level `settings.json`

## Local development

```bash
git clone https://github.com/GiovaneSuss/claude-corner.git
cd claude-corner

make install    # copies commands globally, makes hook executable
# open Claude Code and run /corner:setup to activate
make test       # runs a quick 30s corner session to verify
make uninstall  # removes everything
```

## Customization

Edit `~/claude-corner/PROMPT.md` to change what Claude does in free time.
