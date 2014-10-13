LUA Systêxtil Time Management
====

Set of *Lua* scripts that I use on daily-basis to time tracking at Systêxtil (the company where I work).
They are quite simple, but you may find them useful if you want to connect with Oracle db and need some example.

Dependencies
---

* LuaSQL
* Oracle Instant Client


Tracked Time Yesterday
---

This one intends to check on the db the total time tracked for a specific user or set of users. To use, type:
> lua tracked-time-yesterday.lua 704 719 737 #these are the user codes

Pending
---

The next step is to build a script that inserts time tracking.
