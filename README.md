# Code Checker
Checks your HTML and SASS code.

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

If you get Error: Operation not permitted /usr/bin, try the fix
https://www.macbartender.com/system-item-setup/

You are now ready, run the tool!

###  Option 1: Check HTML code given relative URL's in a file
```bash
code_checker -I urls_list.txt -r http://localhost:3000
```

#### urls_list.txt
```bash
/
/faqs/index.php
/tower/index.php
/restaurant/index.php
```

#### By default HTML is imported into "code_checker_output/imported" folder
You may check the folder to see the resulting HTML that was checked
```bash
/code_checker/imported/index.html
/code_checker/imported/faqs/index.html
/code_checker/imported/tower/index.html
/code_checker/imported/restaurant/index.html
```

### Option 1: with remote server and password
```bash
code_checker -I urls_list.txt -r http://projectx.ryukyu-i.co.jp -u admin -p my_password
```

#### urls_list.txt
```bash
/
/faqs/index.php
/tower/index.php
/restaurant/index.php
```

### Option 2: check local SASS only
Navigate to project folder or SASS directory and specify the folder path
```bash
code_checker -S _dev/_sass
```

Ignore certain folders
```bash
code_checker -S _dev/_sass -X _bootstrap,_animate
```

### Option 3: Check HTML and SASS and do cross-checking
Specify both options 1 and options 2
```bash
code_checker -I urls_list.txt -r http://localhost:3000 -S _dev/_sass
```

### Option 4: Check a single file (for quick debugging)
```bash
code_checker -f index.html
```

```bash
code_checker -f fonts.scss
```

### Option 5: Check HTML files inside a local folder
```bash
code_checker -H mock
```

### Optional: Change the output folder
```bash
code_checker -I urls_list.txt -O my_output_folder
```

### Optional: Turn on certain validators only
Run w3c validation only
```bash
code_checker -I urls_list.txt -V w3c
```

Run ryukyu validation only
```bash
code_checker -I urls_list.txt -V ryukyu
```

Run achecker validation only
```bash
code_checker -I urls_list.txt -V achecker
```

Run both w3c and ryukyu (this is run by default, does not need to be specified)
```bash
code_checker -I urls_list.txt -V w3c,ryukyu,achecker
```

### Help: Get help about usage
```bash
code_checker -h
```

### Checking Details
Checks .html files for basic syntax and coding errors.  Current version checks the following:
- Opening tags must have closing tags
- Closing tags must have opening tags
- Void tags should not have closing tags
- Validity of void tags
- Ryukyu rule: No half-width spaces in Japanese, Korean, and Chinese characters
- Ryukyu rule 9: Only one h1 tag per document, usually for the logo or page title
- Ryukyu rule 15: No "/" character at end of void tags
- Ryukyu rule: img tag needs alt attribute defined

Checks .scss fils for basic syntax and coding errors.  Current version checks the following:
- Ryukyu rule 1: Add @charset "utf-8"; at the first of file
- Ryukyu rule 2: Use min-width instead of max-width as @media breakpoint.
- Ryukyu rule 3: Use px for font-size,don't use em, rem, %... , because it offers absolute control over text.
- Ryukyu rule 4: Use em for line-height, because em can change dynamically with the font in use.
- Ryukyu rule 5: Basic hover checks.  Makes sure hover is defined inside @media for PC.
- Ryukyu rule 5: Makes sure transition is not defined inside hover
- Ryukyu rule 7: Makes sure no styles directly on HTML tags
- Ryukyu rule 10: Don't use flexbox, calc because old version of IE and Android does not support.
- Ryukyu rule 17: Common compass mixins that must be used

Cross checking between .html and .scss files
- Ryukyu rule 5: Makes sure hover styles are applied to 'a', 'input', 'button' tags only
- Ryukyu rule 5: Makes sure all 'a', 'input', and 'button' tags have hover style defined


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
