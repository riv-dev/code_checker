# Code Checker
Checks .html, .hbs, .php, .ejs, and .sass files for basic syntax and coding errors.  Current version checks the following:
- Opening tags must have closing tags
- Closing tags must have opening tags
- Void tags should not have closing tags
- Validity of void tags
- Ryukyu rule: No "/" character at end of void tags
- Ryukyu rule: No half-width spaces in Japanese, Korean, and Chinese characters

Checks .scss fils for basic syntax and coding errors.  Current version checks the following:
- Common compass mixins that must be used
- Basic hover checks.  Makes sure hover is defined inside @media for PC.
- Makes sure transition is not defined inside hover

Cross checking between .html and .scss files
- Makes sure hover styles are applied to 'a' tags only

## Directions to run as a tool on the command line
### Install the tool
Run the following on the command line.  It does not matter which folder you are in.
```bash
sudo gem install specific_install
sudo gem specific_install -l git://github.com/riv-dev/code_checker.git
```

Make sure to check for updates ocassionally by running:
```bash
sudo gem specific_install -l git://github.com/riv-dev/code_checker.git
```

You are now ready, run the tool!

###  Option 1: Check a specific html file
Navigate to the folder or provide full path name.
```bash
code_checker -f index.html
```

### Option 2: Check an entire folder and sub-folders
Navigate to root where folder exists or provide full path name. Example below is for "views" folder.
```bash
code_checker -F views
```

### Option 3: Check multiple folders
```bash
code_checker -F view,_dev/_sass
```

### Option 4: Check all files and folders in current directory
```bash
code_checker -F .
```

### Optional: Exclude files and folder
Use -x for file exclusions.
```bash
code_checker -F . -x index.html
```

Use -X for folder exclusions
```bash
code_checker -F . -X node_modules
```

Allows wildcard matching
```bash
code_checker -F . -x *.ejs
```

Allows multiple files and folders, separate with comma (no white spaces)
```bash
code_checker -F . -x *.ejs,*.php -X node_modules,lib,*temp*
```

### Optional: Check specific file types only (html, hbs, php, ejs)
Code checker checks all supported file types if -t option is not specified.
If -t is specified, it will check those file types only.

#### For example, check only html files:
```bash
code_checker -F . -t html
```

#### For example, check html and hbs files:
```bash
code_checker -F . -t html,hbs
```

#### For example, check only html and php files:
```bash
code_checker -F . -t html,php
```

### Optional: Pipe the output to a logfile
```bash
code_checker -f index.html > log.txt
```

### Help: Get help about usage
```bash
code_checker -h
```

## [Under Construction, do not try yet] Directions to run automatically within Grunt, Ryukyu project
Add the following line to _dev/Gemfile
```ruby
gem 'code_checker', :git => 'git://github.com/riv-dev/code_checker.git'
```

Run "bundle install" on the command line from the _dev directory
```
~/project-path/_dev>bundle install
```

The Ruby GEM should be installed.
