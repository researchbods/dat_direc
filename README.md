[![Build Status](https://travis-ci.org/researchbods/dat_direc.svg?branch=master)](https://travis-ci.org/researchbods/dat_direc)

![Paul Dirac](https://upload.wikimedia.org/wikipedia/commons/thumb/5/50/Paul_Dirac%2C_1933.jpg/220px-Paul_Dirac%2C_1933.jpg)
> "Hey, that's almost my name" - Paul Dirac

Dat Direc
=========

Database Difference Reconciler is a program for looking at the structure of
multiple databases, noting their differences, and, in a semi-automated manner,
generating migrations to reconcile those differences.

Written with MySQL and Rails in mind, I've intended to make it possible to write
plugins to add support for other SQL dump formats and migration systems.
