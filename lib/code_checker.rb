#encoding: utf-8
require 'fileutils'
require 'w3c_validators'
require 'open-uri'
require 'open3'

require_relative 'models/HTMLFile.rb'
require_relative 'models/SASSFile.rb'
require_relative 'models/HTMLFileFactory.rb'
require_relative 'models/RyukyuHTMLValidator.rb'
require_relative 'models/RyukyuSASSValidator.rb'
require_relative 'models/RyukyuCrossValidator.rb'
require_relative 'models/ACheckerValidator.rb'
require_relative 'views/ValidationConsoleView.rb'
require_relative 'views/JSONView.rb'
require_relative 'adapters/ValidationExportAdapter.rb'

include W3CValidators

class CodeChecker

  @@all_html_files = {} #Hash for easy searching
  @@all_sass_files = []

  def self.hi
    puts "Hello World!"
  end

  #Run code checker on a specific file
  def self.check_file(file_path, options)
    code_file = nil
    begin
      captures = file_path.match(/\.(\w+)$/).captures
      if(captures[0] == 'scss')
        code_file = SASSFile.new(file_path)
      else
        code_file = HTMLFileFactory.create(html_file, captures[0])
      end
    rescue
      code_file = HTMLFile.new(file_path)
    end

    return code_file
  end

  def self.import_html(options)

    #Read in the URL's and prepare them accordingly
    if options[:roothost] 
      options[:roothost].chomp.strip.gsub!(/\/$/,'') #remove trailing '/'
    end

    unprocessed_urls = []
    if options[:urlfile]
      urlfile = options[:urlfile]
      f = File.open(urlfile, "r")
      f.each_line do |url|
        unprocessed_urls << url
      end
    elsif options[:url_list]
      unprocessed_urls = options[:url_list]
    end

    #Properly clean and build the urls from the file
    urls = []
    unprocessed_urls.each do |url|
      next if url.chomp.strip.length == 0

      url.chomp.strip!

      if options[:roothost] 
        url = '/' + url unless url.match(/^\//) #Add / before the relative URL if not exist
        url = options[:roothost] + url
      end

      url = "http://" + url unless url.match(/^http/) #Make sure to include http
      url = url.chomp.strip

      urls << url
    end

    #Now that the URL's are ready, import the HTML
    output_folder = options[:output_folder]

    import_folder = output_folder.split('/').push("imported").join('/')

    #Clear the import folder if it already exists
    self.remove_dir(import_folder)

    #Iterate through each URL and import
    urls.each do |url|
      #get the relative path
      relative_request_path = URI.parse(url).request_uri

      if !relative_request_path.match(/\.html\s*$/)
        if relative_request_path.match(/\/\s*$/)
           relative_request_path = relative_request_path + "index.html" 
        else
          relative_request_path = relative_request_path + "/index.html"
        end
      end

      import_file_path = import_folder + relative_request_path

      dirname = File.dirname(import_file_path)

      unless File.directory?(dirname)
        FileUtils.mkdir_p(dirname)
      end

      import_file = File.open(import_file_path,'w')

      if options[:username] and options[:password]
        unless options[:web_api] #suppress output for web api mode, display only results JSON
          puts "Importing #{url} with username=#{options[:username]} and password=#{options[:password]}"
        end

        begin
          open(url, :http_basic_authentication => [options[:username], options[:password]], :redirect => false) { |f|
            f.each_line {|line| import_file << line}
          }
        rescue OpenURI::HTTPRedirect => redirect
          #Handle redirects
          open(redirect.uri.to_s, :http_basic_authentication => [options[:username], options[:password]], :redirect => false) {|f|
            f.each_line {|line| import_file << line}
          }
        end
      else
        unless options[:web_api] #suppress output for web api mode, display only results JSON
          puts "Importing #{url}"
        end
        open(url) {|f| 
          f.each_line {|line| import_file << line}
        }
      end

      import_file.close

      unless options[:web_api] #suppress output for web api mode, display only results JSON
        puts "  Imported #{import_file_path}"
      end
    end

    return import_folder
  end

  def self.remove_imported(options)
    FileUtils.rm_rf(options[:output_folder])
  end

  def self.check_html(folders, options)
    unless options[:web_api] #supress output for web api mode, display only results JSON
      puts "Checking HTML..."
    end
    #Ryukyu Validator
    ryukyu_validator = RyukyuHTMLValidator.new
    #W3C Validator
    w3c_validator = NuValidator.new(:validator_uri => 'https://validator.w3.org/nu/')
    #AChecker Validator
    achecker_validator = ACheckerValidator.new

    folders.each do |folder|
      Dir.glob(folder+"/**/*.html") do |file_name|
        if !self.ignore_file?(file_name, options)
          unless options[:web_api]
            puts "  Checking #{file_name}"
          end
          html_file = HTMLFile.new(file_name)
          @@all_html_files[file_name] = html_file

          if options[:validators] == nil or options[:validators].include?('ryukyu')
            unless options[:web_api]
              puts "    running ryukyu validation..."
            end
            ryukyu_validator.validate(html_file)
          end

          if options[:validators] == nil or options[:validators].include?('w3c')
            begin
              unless options[:web_api]
                puts "    running w3c validation..."
              end
              w3c_results = w3c_validator.validate_file(html_file.file_path)
              html_file.errors.concat(w3c_results.errors)
              html_file.warnings.concat(w3c_results.warnings)
            rescue
              html_file.errors.push(ValidationMessage.new("NA","W3C: service is down.",nil))
            end
          end

          if options[:validators] == nil or options[:validators].include?('achecker')
            begin
              unless options[:web_api]
                puts "    running achecker validation..."
              end
              achecker_results = achecker_validator.validate(html_file.file_path)
              html_file.reports[:achecker] = achecker_results[:report]
              html_file.errors.concat(achecker_results[:errors])
              html_file.warnings.concat(achecker_results[:warnings])
            rescue
              html_file.errors.push(ValidationMessage.new("NA","AChecker: service is down.",nil))        
            end
            #puts results
            #a = File.open('results.html','w')
            #a << results
            #a.close
          end
        end
      end   
    end

    return @@all_html_files
  end

  def self.import_sass(options)
      #Now that the URL's are ready, import the HTML
      output_folder = options[:output_folder]
      
      import_folder = output_folder.split('/').push("imported_sass").join('/')

      FileUtils.mkdir_p(import_folder)
      
      #Clear the import folder if it already exists
      self.remove_dir(import_folder)
    
        #Read in the URL's and prepare them accordingly
        if options[:github_url] 
          options[:github_url].chomp.strip.gsub!(/\/$/,'') #remove trailing '/'
        else
          return
        end
    
        download_urls = []
        imported_sass_folders = []
        if options[:sass_folders]
          options[:sass_folders].each do |relative_url|
            download_url = "#{options[:github_url]}/trunk/#{relative_url}"

            download_command = "svn export #{download_url} #{import_folder}/#{relative_url}"

            if options[:github_username] and options[:github_password]
              download_command = "#{download_command} --non-interactive --no-auth-cache --username #{options[:github_username]} --password #{options[:github_password]}"
            end

            output = `#{download_command}` #Execute system command with back ticks

            unless options[:web_api]
              puts output 
            end

            imported_sass_folders << "#{import_folder}/#{relative_url}".gsub!(/\/\//,'/')

            if options[:exclude_file]
              options[:exclude_files].each.with_index do |filepath, index|
                options[:exclude_file][index] = "#{import_folder}/#{relative_url}/#{filepath}".gsub!(/\/\//,'/')
              end
            end
      
            if options[:exclude_folders]
              options[:exclude_folders].each.with_index do |folderpath, index|
               options[:exclude_folders][index] = "#{import_folder}/#{relative_url}/#{folderpath}".gsub!(/\/\//,'/')
              end      
              #puts "*****#{options[:exclude_folders]}"
            end
          end
        else
          return
        end

        return imported_sass_folders
  end
  
  def self.check_sass(folders, options)
    unless options[:web_api]
      puts "Checking SASS..."
    end

    #Ryukyu Validator
    ryukyu_validator = RyukyuSASSValidator.new

    folders.each do |folder|
      Dir.glob(folder+"/**/*.scss") do |file_name|
        if !self.ignore_file?(file_name, options)
          unless options[:web_api]
            puts "  Checking #{file_name}"
          end
          sass_file = SASSFile.new(file_name)
          @@all_sass_files << sass_file
          unless options[:web_api]
            puts "    running ryukyu validation..."
          end
          ryukyu_validator.validate(sass_file)
        end
      end     
    end

    return @@all_sass_files
  end

  def self.cross_check_html_sass(html_files,sass_files)
    ryukyu_validator = RyukyuCrossValidator.new
    unless options[:web_api]
      puts "Performing cross validation between HTML and SASS..."
    end
    results = ryukyu_validator.validate(html_files,sass_files)
    return results
  end

  def self.clear_output_folder(output_folder)
    self.remove_dir(output_folder)
  end

  def self.display_console(code_file)
    ValidationConsoleView.display(code_file)
  end

  def self.display_all_console(code_files)
    ValidationConsoleView.display_all(code_files)
  end

  def self.display_json(code_file)
    JSONView.display(code_file)
  end

  def self.display_all_json(code_files)
    JSONView.display_all(code_files)
  end

  def self.export_result(code_file, output_folder)
    ValidationExportAdapter.export_result(code_file, output_folder)
  end

  def self.export_all_results(code_files, output_folder)
    ValidationExportAdapter.export_all_results(code_files, output_folder)
  end

  private
  #Helper functions
  #Returns true if options have been set to ignore the file
  def self.ignore_file?(path, options)
    path_components = path.split("/");
    filename = path_components.last

    #import file and folder exclusion options
    @@exclude_files = options[:exclude_files]
    @@exclude_folders = options[:exclude_folders]

    if @@exclude_files != nil
      @@exclude_files.each do |exclude_file|
        #Check for wildcards in exclude_file name
        if exclude_file.match(/\*.+\*/) #match front and back
          term = exclude_file.gsub(/\*/,'')
          return true if filename.match(/#{term}/)
        elsif exclude_file.match(/\*.*\w$/) #match back only
          term = exclude_file.gsub(/\*/,'')
          return true if filename.match(/#{term}$/)
        elsif exclude_file.match(/.+\*$/) #match front only
          term = exclude_file.gsub(/\*/,'')
          return true if filename.match(/^#{term}/)
        else #no wildcard, match exactly
          return true if filename == exclude_file
        end
      end  
    end

    path_components.pop #pop off the filename, leave the folder path only

    if @@exclude_folders != nil
      @@exclude_folders.each do |exclude_folder|
        #Check for wildcards in exclude_folder name
        if exclude_folder.match(/\*.+\*/) #match front and back
            term = exclude_folder.gsub(/\*/,'')
            return true if path_components.join("/").match(/#{term}/)
          elsif exclude_folder.match(/\*.*\w$/) #match back only
            term = exclude_folder.gsub(/\*/,'')
            return true if path_components.join("/").match(/#{term}$/)
          elsif exclude_folder.match(/.+\*$/) #match front only
            term = exclude_folder.gsub(/\*/,'')
            return true if path_components.join("/").match(/^#{term}/)
          else #no wildcard, match exactly
            return true if path_components.join("/").match(/^#{exclude_folder}/)
          end
      end
    end

    return false
  end

  def self.remove_dir(path)
    if File.directory?(path)
      Dir.foreach(path) do |file|
        if ((file.to_s != ".") and (file.to_s != ".."))
          self.remove_dir("#{path}/#{file}")
        end
      end
      Dir.delete(path)
    else
      begin
        File.delete(path)
      rescue
      end
    end
  end  

end