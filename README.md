# ls0: a "ls" that separates results with a null terminator

ls0 - List filenames, with each output null-terminated.

# Synopsis

ls0 \[options\] \[--\] \[pathspecs\]

Run ls0 --help for options, or ls0 --man for full documentation.
By default, if no pathspecs or atfiles are given, ls0 will:

- if stdin is a tty,

    list files in the current directory;

- otherwise,

    take NULL-separated input from stdin and list it.

Example: `find . -name 'some*pattern' -print0 | ls0 -t`
displays filenames matching `some*pattern`, newest first,
even if those filenames contain special characters.

# Options

- **-a**

    Also list files beginning with a `.`

- **-A**

    Also list files beginning with a `.`, except for `.` and `..`

- **-b**, **--escape** (disable with **--noescape**)

    Print octal escapes for special characters and backslashes
    (which are `\134`).
    Implies **--eol** (newline terminators);
    also specify **--noeol** if you still want null terminators.

    By default, output is escaped if standard output is a terminal.

    If multiple escaping options are given, **--noescape** controls (if specified).

- **-d**

    List directories as directories; don't list their contents.  Overrides **-R**.
    Can't be used with **--rglob**.

- **-e &lt;field>**, **--echo &lt;field>**

    **Not yet implemented.**
    Output **&lt;field>** for each file to be printed.  Multiple **-e** options
    can be specified, and the fields will be output in that order.
    Each field will be terminated by the output terminator (see **--eol**).

- **--eol** (disable with **--noeol**)

    Terminate output entries with a platform-specific end-of-line sequence
    rather than a NULL.  May be useful with **--glob**.

    By default, the terminator is NULL unless **--eol** is given or escaping is
    active (by default or by **-b** or **--escape**).

    If multiple escaping or terminator entries are given, **--noeol** controls
    (if specified).

- **--from &lt;atfile>**, **-@ &lt;atfile>**

    Read the pathspecs to be processed from **atfile**; specify `-` to read from
    standard input.  Each pathspec in **atfile** should
    be separated by a NULL terminator (`\0`).  This is ls\_0\_, after all.
    The input is read in binary mode, so filenames can contain any non-NULL
    character.

    See ["Reading atfiles"](#reading-atfiles) for details.

- **--fromeol &lt;atfile>**

    As **--from**, but each pathspec in **atfile**
    should be separated by a platform-specific end-of-line.

    See ["Reading atfiles"](#reading-atfiles) for details.

- **--glob**

    Expand the provided pathspecs using perl's `File::Glob::bsd_glob`.
    This is provided for shells that don't glob, or don't glob as you expect.
    Make sure to quote the arguments if necessary to prevent your shell from
    globbing before ls0 sees them.

- **--leaf**

    Only list leaves, i.e., files plus directories for which no lower-level files
    are being listed.

- **-r**

    Reverse the order of the sort.  Cannot be used with **-U** (unsorted listing).

- **-R**

    Visit subdirectories recursively.  No effect if **-d** is specified.

- **--rglob**

    Glob in ls0 rather than (or in addition to) in the shell.  Try to glob
    the pathspecs given on the command line in each directory visited.
    Implies **-R** and **--glob**.  Can't be used with **-d**.

- **-S**

    Sort by file size, descending by default.

- **-t**

    Sort by time, newest first (unless **-r**).  Uses the modification time
    unless **--time** is given.

- **--time &lt;timeval>**

    Use **&lt;timeval>** as the time when sorting.  Run `ls0 -t --time=?` to see
    the list of available times.  At least **atime**, **ctime**, and **mtime**
    are available.

- **-U**

    Don't sort the results - you get them in whatever order you get them.
    This will likely be the breadth-first search order ls0 currently uses,
    but you **shall not** make any assumptions about name order when using
    this option.  Cannot be used with **-r**.

- **--xargs**

    A convenient synonym for `--from -`.  For example, instead of
    `find ... | xargs ls`, you can use `find ... -print0 | ls0 --xargs`
    to get the same effect with the benefits of (1) the safety NULL terminators
    provide, and (2) support for a higher match count than the command line
    can handle.

    This is the default unless:

    - the input is a tty;
    - you have provided at least one pathspec on the command line; or
    - you have named at least one atfile on the command line.

## Reading atfiles

The **--from** and **--fromeol** options read atfiles and treat entries in those
files as if those entries had been specified on the command line.  Things to
bear in mind:

- Since entries are as if specified on the command line, they are subject to
**-d**, **-R**, and other options that affect how command-line parameters are
treated.  For example,
`echo 'foo/' | ls0 --fromeol -` will list the
contents of directory `foo`, whereas
`echo 'foo/' | ls0 --fromeol - -d` (with **-d**) will list the
name of directory `foo`.

    This may be an issue when piping `find` output into ls0;
    see ["Trimming duplicates"](#trimming-duplicates) for details and workarounds.

- The filename `-` refers to standard input.
- You can't specify the same **atfile** for more than one
**--from** or **--fromeol** option.
- You **shall not** make any assumptions about the relative order of items
listed on the command line or in atfiles.  In any case, the output order is
controlled only by any sorting options you provide.
- **--fromeol** does not unescape any
characters.  If you use this, make sure the filenames in **atfile** don't
contain end-of-line characters.
- **--fromeol** uses the platform-specific newline sequence, e.g.,
`\r`, `\n`, or `\r\n`.  If you try to read
DOS text files on a UNIX ls0, the input entries will have extra "\\r"
characters at the end of them.

# Differences between GNU ls(1) and ls0(1)

## New features

- **-e &lt;field>**, **--echo &lt;field>**

    Output only specific fields.  Each field is separated by the output terminator
    rather than being printed together on a line.  That way a single loop can
    read all the output values for all the matched files.

- **--from &lt;atfile>**, **--fromeol &lt;atfile>**

    Read input pathspecs from **atfile**.

- **--glob**

    Glob in ls0 rather than (or in addition to) in the shell.

- **--rglob**

    Glob in ls0 rather than (or in addition to) in the shell, and glob in each
    subdir.

- **--leaf**

    Only list leaves.

## Unsupported ls(1) features

The following GNU ls(1) options are not supported by ls0:

- **-1** (print single line), **-C** (list down columns),
**-m** (comma-separated output), **-x** (list across rows), **--format**,
**-T**, **--tabsize**, **-w**/**--width**

    We don't print these formats; we only support NULL and EOL as delimiters,
    and don't do multicolumn or fixed column widths.
    Our **-b** implies one line per output item.

- **-l**/**-g**/**-o** (long listings), **--full-time**,
**-s** (print sizes)

    We use **-e**, instead of these options, to specify which fields to output.

- **-F**/**--file-type**/**--indicator-style**/**-p** (print indicators),
**-N**/**--literal** (print names literally), **-q** (hide control chars),
**--show-control-chars** (print control characters raw),
**-Q**/**--quote-name** (quote output), **--quoting-style**

    We only print raw or with backslash escapes (**-b**), so we don't support these.

- **--color**

    Nope.  Sorry!

- **-D**

    Long live vi!

- **--lcontext**, **-Z**, **--context**

    We don't support SELinux at this time.

## Differences in behaviour

### Default search order

ls(1) sorts case-insensitively by default, e.g., `alpha, BAR, foo, QUUX`.
We sort on byte values without regard to case or encoding, e.g.,
`BAR, QUUX, alpha, foo` (in ASCII).

### Output format for multiple subdirectories

When listing multiple directories, e.g., `ls foo/ bar/`, ls(1) shows:

    foo:
    file_in_foo

    bar:
    file_in_bar

However, ls0(1) is intended for machine output, so it produces:

    foo
    foo/file_in_foo
    bar
    bar/file_in_bar

in whatever order you have specified by the sort options.  With **-U**, for
example, you may get:

    foo
    bar
    foo/file_in_foo
    bar/file_in_bar

(the breadth-first order), although you may get a different order.

# Notes

## Trimming duplicates

The command `find . -print0 | ls0` will
print two copies of every entry in `.`, since
the entries are printed as part of processing of `.` and also
as the individual entries output by find(1).  (The same
happens with ls(1).)  To trim these duplicates, you can:

- Use **-d**:

    `find . -print0 | ls0 -d` will print `.` as itself, and not expand its
    contents.

- Exclude `.` from the `find` results:

    `find . -name '.' -o -print0` will cause `find` to omit `.`
    from its results.  Therefore, ls0 will not process `.`, and so will not
    expand its contents.

# Copyright

Copyright (c) 2016--2018 Chris White [http://www.devwrench.com](http://www.devwrench.com)
CC-BY-SA 3.0

Inspired by [https://stackoverflow.com/a/41168189/2877364](https://stackoverflow.com/a/41168189/2877364) by
myself, [cxw](https://stackoverflow.com/users/2877364/cxw).
Code based in part on [http://stackoverflow.com/a/13999717/2877364](http://stackoverflow.com/a/13999717/2877364) by
[turningtaxis](http://stackoverflow.com/users/1922919/turningtaxis)
and on [http://stackoverflow.com/a/3960071/2877364](http://stackoverflow.com/a/3960071/2877364) by
[ruel](http://stackoverflow.com/users/459338/ruel).
