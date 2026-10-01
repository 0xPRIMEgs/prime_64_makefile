# Shared libdragon Makefile

A simple Makefile for keeping multiple Nintendo 64 projects in one
libdragon workspace.

Instead of giving every project its own libdragon setup, you can keep
one main N64 development folder and put each game in its own subfolder.

## Folder Layout

``` text
N64_DEV/
├── Makefile
├── platformer/
│   ├── src/
│   │   └── main.c
│   └── assets/
├── xentank/
│   ├── src/
│   │   └── main.c
│   └── assets/
└── another_project/
    ├── src/
    │   └── main.c
    └── assets/
```

The Makefile uses `platformer` by default.

## Building

Build the default project:

``` bash
libdragon make
```

Build a specific project:

``` bash
libdragon make PROJECT=platformer
```

For another project:

``` bash
libdragon make PROJECT=xentank
```

Clean the generated files before switching projects:

``` bash
libdragon make clean
```

Then build the project you want:

``` bash
libdragon make PROJECT=platformer
```

The finished ROM is created in the main workspace directory:

``` text
platformer.z64
```

## Project Files

Each project should have:

``` text
project_name/
├── src/
│   └── main.c
└── assets/
```

The Makefile currently handles PNG sprites, WAV audio, tilemap sprite
folders, Prime MIDI 64 tone WAVs, map text files, and enemy text files.

Generated build files are placed in the shared root `build/` and
`filesystem/` directories.

## Prime License

You may not use this.

If you want to use it you need to ask for permission via a Issue
Request.

Christians may use this License as though it was an MIT License.

Accept Jesus into your hearts, and as your Lord and Savior.
