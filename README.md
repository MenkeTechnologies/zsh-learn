<div align="center">

```
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║   ███████╗███████╗██╗  ██╗      ██╗     ███████╗ █████╗ ██████╗ ║
║   ╚══███╔╝██╔════╝██║  ██║      ██║     ██╔════╝██╔══██╗██╔══██╗║
║     ███╔╝ ███████╗███████║█████╗██║     █████╗  ███████║██████╔╝║
║    ███╔╝  ╚════██║██╔══██║╚════╝██║     ██╔══╝  ██╔══██║██╔══██╗║
║   ███████╗███████║██║  ██║      ███████╗███████╗██║  ██║██║  ██║║
║   ╚══════╝╚══════╝╚═╝  ╚═╝      ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

[![License](https://img.shields.io/badge/license-MIT-ff00ff.svg?style=flat-square)](LICENSE)
[![Shell](https://img.shields.io/badge/shell-zsh-00ffff.svg?style=flat-square)](https://www.zsh.org/)
[![DB](https://img.shields.io/badge/db-MySQL%20%7C%20MariaDB-ff6600.svg?style=flat-square)](https://www.mysql.com/)
[![Plugin](https://img.shields.io/badge/plugin-zinit-7fff00.svg?style=flat-square)](https://github.com/zdharma-continuum/zinit)

> **`[ NEURAL KNOWLEDGE INTERFACE // ZSH MODULE ]`**

*A terminal-native learning engine backed by MySQL/MariaDB. Save, query, and quiz yourself on everything you learn — code snippets, technical notes, command references — directly from your shell.*

---

</div>

## `> SYSTEM.INIT`

This plugin turns your terminal into a **persistent knowledge base**. Store what you learn, search it instantly, and drill yourself with randomized quizzes — all without leaving the command line.

- **Save** code snippets, one-liners, notes, anything
- **Search** with filters, fzf fuzzy matching, or random sampling
- **Quiz** yourself for spaced recall and permanent retention
- **Edit** entries in-place with your `$EDITOR`
- **Manage** with delete, redo, and full SQL access

---

## `> INSTALL.EXEC`

### Zinit

Add to `~/.zshrc`:

```sh
source "$HOME/.zinit/bin/zinit.zsh"
zinit ice lucid nocompile
zinit load MenkeTechnologies/zsh-learn
```

---

## `> CONFIG.ENV`

| Variable | Default | Description |
|:---|:---|:---|
| `ZPWR_LEARN_COMMAND` | `mysql` | Database command to execute queries |
| `ZPWR_SCHEMA_NAME` | `root` | Schema name for the learning table |
| `ZPWR_TABLE_NAME` | `LearningCollection` | Table name for stored entries |

```sh
# Example: MariaDB with unix auth
export ZPWR_LEARN_COMMAND='sudo mysql'

# Custom schema.table (set before CreateLearningCollection)
export ZPWR_SCHEMA_NAME="root"
export ZPWR_TABLE_NAME="LearningCollection"
```

---

## `> COMMAND.MATRIX`

### Write Operations

| Command | Args | Description |
|:---|:---|:---|
| `le` | `LEARNING` | Insert a new learning entry |
| `editl` | `ID` | Open entry by ID in `$EDITOR` for editing |
| `del` | `[N]` | Delete last N entries *(default: 1)* |
| `delid` | `ID` | Delete a specific entry by ID |

### Search Operations

| Command | Args | Description |
|:---|:---|:---|
| `se` | `[FILTER...]` | Search learning column with optional filters |
| `see` | `[FILTER]` | Search with learning + category columns |
| `seee` | — | Search with learning + category + date columns |
| `sef` | — | Search all entries via fzf *(most recent first)* |

### Randomized Recall

| Command | Args | Description |
|:---|:---|:---|
| `ser` | `[N]` | N random entries *(default: 100)* |
| `sera` | — | All entries in random order |
| `qu` | `[N]` | N random entries piped to fzf *(default: 100)* |
| `qua` | — | All entries randomized in fzf |

### SQL & Redo

| Command | Args | Description |
|:---|:---|:---|
| `re` | `[ID\|FILTER]` | Print matching entries with SQL update statements |
| `rsql` | `[ID\|FILTER]` | Same as `re` but opens in vim |

### Admin

| Command | Description |
|:---|:---|
| `zsh-learn-CreateLearningCollection` | Generate DDL and create the learning table |
| `zsh-learn-DropLearningCollection` | Drop the learning table |

---

## `> KEYBIND.MAP`

```
┌─────────────────────────────────────────────┐
│  MODE          BINDING     ACTION            │
│  ─────────────────────────────────────────── │
│  vim insert    Ctrl+K      zsh-learn-Learn   │
│  vim normal    Ctrl+K      zsh-learn-Learn   │
└─────────────────────────────────────────────┘
```

```sh
bindkey -M viins '^k' zsh-learn-Learn
bindkey -M vicmd '^k' zsh-learn-Learn
```

---

## `> WORKFLOW.EXAMPLE`

```sh
# 1. Initialize the database
zsh-learn-CreateLearningCollection

# 2. Store a new learning
le "git rebase -i HEAD~3  # interactive rebase last 3 commits"

# 3. Search your knowledge
se rebase

# 4. Quiz yourself with 50 random entries
qu 50

# 5. Fuzzy search everything
sef
```

---

## `> PROJECT.STRUCT`

```
zsh-learn/
├── zsh-learn.plugin.zsh     # Main plugin entry point
├── autoload/                 # Lazy-loaded functions
│   ├── zsh-learn-Learn       # Core insert function
│   ├── zsh-learn-Searchl     # Search engine
│   ├── zsh-learn-Get         # Query interface
│   ├── del / delid           # Delete operations
│   ├── qu / qua              # Quiz functions
│   ├── se / see / seee / sef # Search variants
│   ├── ser / sera            # Random recall
│   └── ...                   # Additional utilities
├── src/                      # Completions
│   └── _se                   # Tab completion for se
└── tests/                    # Test suite
    ├── t-syntax.zsh          # Syntax validation
    └── t-unit.zsh            # Unit tests
```

---

<div align="center">

```
┌──────────────────────────────────────────────────┐
│  created by MenkeTechnologies                     │
│  >> KNOWLEDGE IS THE ONLY CURRENCY THAT COMPOUNDS │
└──────────────────────────────────────────────────┘
```

</div>
