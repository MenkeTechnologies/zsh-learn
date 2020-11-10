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

You change the database command to run by exporting this environment variable with a custom database command.  The default command is mysql.
```sh
export ZPWR_LEARN_COMMAND=mysql
```
For example with MariaDB unix auth plugin you would change to:
```sh
export ZPWR_LEARN_COMMAND='sudo mysql'
```

## Functions

- le (short for learn)

Take the first arg as the learning text and inserts into learning table

- se (short for search)

Selects learning column from all records from the learning table

- del (short for delete)

Deletes last item from table

- sef (short for search fzf)

Selects all from the learning table into fzf with most recent first

- see(short for search extra)


Selects learning and category columns from all records from the learning table

- seee(short for search extra extra)


Selects learning, category and date columns from all records from the learning table

- ser(short for search random)


Selects learning column from 100 random records from the learning table
First arg is number of random records

- sera(short for search random all)


Selects learning column from all random records from the learning table

- qu(short for quiz)


Selects learning column from 100 random records from the learning table into fzf
First arg is number of random records

- qua(short for quiz all)


Selects learning column from alll random records from the learning table into fzf


- redo

Selects learning column from last records from the learning table and print to prompt with SQL update statements.
One or more args are the number order records to print to prompt

- rsql (short for redo sql)


Selects learning column from last records from the learning table and print to vim with SQ update statements.
One or more args are the number order records to print to prompt

- createLearningCollection

Creates the learning table, generates DDL


## ZLE Keybindings
```sh
bindkey -M viins '^k' learn
bindkey -M vicmd '^k' learn
```

Control-k is bound to the learn function in vim insert and normal modes


## created by MenkeTechnologies
