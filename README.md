```
███████╗███████╗██╗  ██╗       ██╗     ███████╗ █████╗ ██████╗ ███╗   ██╗
╚══███╔╝██╔════╝██║  ██║       ██║     ██╔════╝██╔══██╗██╔══██╗████╗  ██║
  ███╔╝ ███████╗███████║ █████╗██║     █████╗  ███████║██████╔╝██╔██╗ ██║
 ███╔╝  ╚════██║██╔══██║ ╚════╝██║     ██╔══╝  ██╔══██║██╔══██╗██║╚██╗██║
███████╗███████║██║  ██║       ███████╗███████╗██║  ██║██║  ██║██║ ╚████║
╚══════╝╚══════╝╚═╝  ╚═╝       ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝
```

[![CI](https://github.com/MenkeTechnologies/zsh-learn/actions/workflows/ci.yml/badge.svg)](https://github.com/MenkeTechnologies/zsh-learn/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![zsh](https://img.shields.io/badge/zsh-plugin-cyan.svg)](https://github.com/MenkeTechnologies/zpwr)

### `[MYSQL-BACKED LEARNING COLLECTION FOR ZSH // SAVE, QUERY, QUIZ]`

> *"Every command you forgot, recoverable."*

### [`strykelang`](https://github.com/MenkeTechnologies/strykelang) &middot; [`zshrs`](https://github.com/MenkeTechnologies/zshrs) · [`MenkeTechnologiesMeta`](https://github.com/MenkeTechnologies/MenkeTechnologiesMeta) · [`zsh-more-completions`](https://github.com/MenkeTechnologies/zsh-more-completions) · [`zsh-git-acp`](https://github.com/MenkeTechnologies/zsh-git-acp) · [`zsh-expand`](https://github.com/MenkeTechnologies/zsh-expand) · [`zpwr`](https://github.com/MenkeTechnologies/zpwr)

---

## Table of Contents

- [\[0x00\] `> SYSTEM.INIT`](#0x00-systeminit)
- [\[0x01\] `> INSTALL.EXEC`](#0x01-installexec)
- [\[0x02\] `> CONFIG.ENV`](#0x02-configenv)
- [\[0x03\] `> COMMAND.MATRIX`](#0x03-commandmatrix)
- [\[0x04\] `> KEYBIND.MAP`](#0x04-keybindmap)
- [\[0x05\] `> WORKFLOW.EXAMPLE`](#0x05-workflowexample)
- [\[0x06\] `> PROJECT.STRUCT`](#0x06-projectstruct)

---

## [0x00] `> SYSTEM.INIT`

This plugin turns your terminal into a **persistent knowledge base**. Store what you learn, search it instantly, and drill yourself with randomized quizzes — all without leaving the command line.

- **Save** code snippets, one-liners, notes, anything
- **Search** with filters, fzf fuzzy matching, or random sampling
- **Quiz** yourself for spaced recall and permanent retention
- **Edit** entries in-place with your `$EDITOR`
- **Manage** with delete, redo, and full SQL access

---

## [0x01] `> INSTALL.EXEC`

### Zinit

Add to `~/.zshrc`:

```sh
source "$HOME/.zinit/bin/zinit.zsh"
zinit ice lucid nocompile
zinit load MenkeTechnologies/zsh-learn
```

---

## [0x02] `> CONFIG.ENV`

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

## [0x03] `> COMMAND.MATRIX`

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

## [0x04] `> KEYBIND.MAP`

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

## [0x05] `> WORKFLOW.EXAMPLE`

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

## [0x06] `> PROJECT.STRUCT`

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

