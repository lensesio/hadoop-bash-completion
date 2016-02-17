# Hadoop Bash Completion #

A script that adds bash completion for hadoop commands. It completes commands, switches and **HDFS paths**.
The latter is our main contribution to the script which has a history from
[facebook](https://github.com/facebookarchive/hadoop-20/tree/master/src/contrib/bash-tab-completion)
and [guozheng](https://github.com/guozheng/hadoop-completion).

## Usage

Simplest way to use it, is to source it:

    source /path/to/hadoop-completion.sh

For permanent use you should source it from your bashrc:

    echo "source /path/to/hadoop-completion.sh" >> ~/.bashrc

You may also add it to your current bash-completion scripts' collection.

Enjoy. :)
