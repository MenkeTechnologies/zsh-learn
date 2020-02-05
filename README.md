# zsh-learn


This plugin contain all functionality to have a a learning collection stored in MySQL/MariadB.

## functions

- le

Take the first arg as the learning text and inserts into learning table

- se

Selects learning column from all records from the learning table

- del

Deletes last item from table

- sef

Selects all from the learning table into fzf with most recent first

- see

Selects learning and category columns from all records from the learning table

- seee

Selects learning, category and date columns from all records from the learning table

- ser

Selects learning column from 100 random records from the learning table
First arg is number of random records

- qu

Selects learning column from 100 random records from the learning table into fzf
First arg is number of random records


- redo

Selects learning column from last records from the learning table and print to prompt with SQL update statements.
One or more args are the number order records to print to prompt

- rsql

Selects learning column from last records from the learning table and print to vim with SQ update statements.
One or morer args are the number order records to print to prompt

- createLearningCollection

Creates the learning table, generates DDL


## keybindings
```sh
bindkey -M viins '^k' learn
bindkey -M vicmd '^k' learn
```

Control-k is bound to the learn function in vim insert and normal modes


## created by MenkeTechnologies
