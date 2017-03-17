# Code Checker
Checks .html, .hbs, .php, and .ejs, files for basic syntax and coding errors.  Current version checks the following:
- Opening tags must have closing tags
- Closing tags must have opening tags
- Void tags should not have closing tags
- Validity of void tags
- Ryukyu rule: No "/" character at end of void tags
- Ryukyu rule: No half-width spaces in Japanese, Korean, and Chinese characters
- Ryukyu rule: Only one h1 tag per document, usually for the logo or page title

Checks .scss fils for basic syntax and coding errors.  Current version checks the following:
- Common compass mixins that must be used
- Basic hover checks.  Makes sure hover is defined inside @media for PC.
- Makes sure transition is not defined inside hover
- Use min-width instead of max-width as @media breakpoint.
- Use em for line-height, because em can change dynamically with the font in use.
- Use px for font-size,don't use em, rem, %... , because it offers absolute control over text.
- Makes sure no styles directly on HTML tags
- Don't use flexbox, calc because old version of IE and Android does not support.

Cross checking between .html and .scss files
- Makes sure hover styles are applied to 'a', 'input', 'button' tags only
- Makes sure all 'a', 'input', and 'button' tags have hover style defined

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

### Option 2: Check entire folders and sub-folders
Navigate to root where folders exists or provide full path name. Example below is for "views" and "_dev/_sass" folders.
```bash
code_checker -F views,_dev/_sass
```

### Option 3: Check all files and folders in current directory
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
code_checker -f index.html -o log.txt
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
