## Directions to run as a tool on the command line
Install the tool by running the following on the command line.  It does not matter which folder you are in.
```bash
gem install specific_install
gem specific_install -l git://github.com/riv-dev/code_checker.git
```

Make sure to check for updates ocassionally by running:
```bash
gem specific_install -l git://github.com/riv-dev/code_checker.git
```

You are now ready, run the tool!

### Option 1: Check a specific html file
```bash
code_checker -f index.html
```

### Option 2: Check an entire folder and sub-folders
```bash
code_checker -F views
```

### Option 3: Check all files and folders in current directory
```bash
code_checker -F .
```

### Pipe the output to a logfile
```bash
code_checker -f index.html > log.txt
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
