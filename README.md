<img src=logo.png height=120px> <br>
# Clean Document File
#### A Shell (bash) Script that uses native zip and unzip UNIX commands to edit ODT's and DOCX's metadata

**Cl**ear **Doc**ument **f**iles (aka **cldocf**) is a (stupidly) symple Shell (bash) Script that uses native zip and unzip UNIX commands to edit ODT's and DOCX's metadata by replacing the content of some XML files and repacking the docs. It is meant for  simple use: like sending a "fully anonimized" copy of a file to a Journal that asks for clean metadata.

Developed by: _betor_(https://github.com/BetoNetu) <br>
License: GNU/AGPL-V3

## Instalation

1. Clone the repository
2. Execute cldocf/install.sh
```bash
git clone https://github.com/BetoNetu/cldocf
cd cldocf #go into created dir
bash ./install.sh
```

## Usage
```bash
cldocf [options] file.extension
-v, --verbose   #Enable verbose output
-l, --logging   #Enable verbose logging
-d, --data      #Show the replaced metadata files and new content
-h, --help      #Show this help
```