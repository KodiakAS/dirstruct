## Copy directory structure from src to dst.

Example1: copy structure of `root` to `newdir`

    dirstruct.sh copy root newdir

    root
    ├── .foo
    ├── dir1
    │   ├── subdir1
    │   └── subdir2
    └── dir2

    newdir
    └── root
        ├── .foo
        ├── dir1
        │   ├── subdir1
        │   └── subdir2
        └── dir2

    dirstruct.sh copy root newdir -i
    * hidden directories will be ignored

    newdir
    └── root
        ├── dir1
        │   ├── subdir1
        │   └── subdir2
        └── dir2

Example2: save structure of directory `root` into file `root.tree`

    dirstruct.sh tree root

    cat root.tree
    root
    root/.foo
    root/dir2
    root/dir1
    root/dir1/subdir2
    root/dir1/subdir1

    Similarly，you can ignore hidden directories by using `-i` flag
