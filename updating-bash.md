# Updating Bash

1. Check your version of Bash (we will want the latest, 4.4.23(1)-release). For example

```shell
$ bash --version
3.2.53(1)-release
```

2. Use HomeBrew to install the version of Bash...

```shell
$ brew update && brew install bash
```

3. Check version of Bash that's installed.

```shell
$ bash --version
4.4.23(1)-release
```

4. Check the version that is running.

```shell
$ echo $BASH_VERSION
3.2.53(1)-release
```

5. Add the new Bash location `/usr/local/bin/bash` to the list of allowed shells `/etc/shells`, either manually or via cmd.

```shell
sudo bash -c 'echo /usr/local/bin/bash >> /etc/shells'
```

6. Now change to use it, and restart the terminal shell.

```shell
chsh -s /usr/local/bin/bash
```

7. Confirm Bash version that is running.

```shell
$ bash --version
GNU bash, version 4.4.23(1)-release (x86_64-apple-darwin16.7.0)
Copyright (C) 2016 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

This is free software; you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
```

```shell
$ echo $BASH_VERSION
4.4.23(1)-release
```
