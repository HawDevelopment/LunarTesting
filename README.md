# LunarTesting

LunarTesting is a testing module for lua, I plan to add more features in the future.
This was originally a port of [BoatTEST](https://github.com/boatbomber/BoatTEST) to lua.

# Usage

Use the `test` command to run tests. This can be a directory or a file.
For convinience, theres provided a `-d` option to explicitly say its a directory.

```bash
$ lua Lunar.lua test <file or folder>
```

# Options

-   `--Os` - Specify the OS to run, Lunar already performs auto OS.
-   `--directory` - Explicitly tell Lunar that the current test file is a directory.
-   `--verbose` - Adds extra logs to the output.
