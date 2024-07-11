# zsh-learn


This plugin contains functionality to have a learning collection in MySQL/MariaDB to save, query and quiz everything you learn.
I store code snippets and other technical information in my personal learning collection.
This helps initial learning, recall and relearning for permanent knowledge.

## Install for Zinit
> `~/.zshrc`
```sh
source "$HOME/.zinit/bin/zinit.zsh"
zinit ice lucid nocompile
zinit load MenkeTechnologies/zsh-learn
```

### Environment variables
You change the database command to run by exporting this environment variable with a custom database command.  The default command is mysql.
```sh
export ZPWR_LEARN_COMMAND=mysql
```
For example with MariaDB unix auth plugin you would change to:
```sh
export ZPWR_LEARN_COMMAND='sudo mysql'
```
Change the schema.table default values with these environment variables. Before `zsh-learn-CreateLearningCollection` if schema.table do not exist.
```sh
export ZPWR_SCHEMA_NAME="root"
export ZPWR_TABLE_NAME="LearningCollection"
```

## Functions

Take LEARNING as the learning text and inserts into learning table

- le LEARNING (short for learn)

Selects learning column from all records from the learning table with optional FILTERs

- se [FILTER...] (short for search)

Find and edit a learning by ID. Opens in default text editor.

- editl ID (short for edit learning)

Deletes N last items from table, default N = 1

- del [N] (short for delete)

Deletes a specific ID from the learning table

- delid ID (short for delete by id)

Selects all from the learning table into fzf with most recent first

- sef (short for search fzf)

Selects learning and category columns from all records from the learning table with optional FILTER

- see [FILTER](short for search extra)

Selects learning, category and date columns from all records from the learning table

- seee(short for search extra extra)

Selects learning column from N random records from the learning table, default N = 100

- ser N (short for search random)

Selects learning column from all random records from the learning table

- sera(short for search random all)

Selects learning column from N random records from the learning table into fzf, default N = 100

- qu N (short for quiz)

Selects learning column from alll random records from the learning table into fzf

- qua(short for quiz all)

Selects learning column from last records from the learning table and print to prompt with SQL update statements.
Arguments are either integer ID or string FILTER to select 1 or more records that match.

- re [ID|FILTER]

Selects learning column from last record from the learning table and print to vim with SQL update statements.
Arguments are either integer ID or string FILTER to select 1 or more records that match.

- rsql [ID|FILTER] (short for redo sql)

Creates the learning table, generates DDL

- zsh-learn-CreateLearningCollection


## ZLE Keybindings
```sh
bindkey -M viins '^k' zsh-learn-Learn
bindkey -M vicmd '^k' zsh-learn-Learn
```

Control-k is bound to the learn function in vim insert and normal modes


## created by MenkeTechnologies
