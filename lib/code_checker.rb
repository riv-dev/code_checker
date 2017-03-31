require 'fileutils'
require 'w3c_validators'
require 'open-uri'

require_relative 'models/HTMLFile.rb'
require_relative 'models/SASSFile.rb'
require_relative 'models/HTMLFileFactory.rb'
require_relative 'models/RyukyuHTMLValidator.rb'
require_relative 'models/RyukyuSASSValidator.rb'
require_relative 'models/RyukyuCrossValidator.rb'
require_relative 'models/ACheckerValidator.rb'
require_relative 'views/ValidationConsoleView.rb'
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

  def self.import_html(urlfile, options)
    urls = []

    #Read in the URL's and prepare them accordingly
    if options[:roothost] 
      options[:roothost].chomp.strip.gsub!(/\/$/,'') #remove trailing '/'
    end
    f = File.open(urlfile, "r")
    #Properly clean and build the urls from the file
    f.each_line do |url|
      next if url.chomp.strip.length == 0

      url.chomp.strip!

      if options[:roothost] 
        url = '/' + url unless url.match(/^\//)
        url = options[:roothost] + url
      end

      url = "http://" + url unless url.match(/^http/)
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
        puts "Importing #{url} with username=#{options[:username]} and password=#{options[:password]}"
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
        puts "Importing #{url}"
        open(url) {|f| 
          f.each_line {|line| import_file << line}
        }
      end

      import_file.close

      puts "  Imported #{import_file_path}"
    end

    return import_folder
  end

  def self.check_html(folders, options)
    puts "Checking HTML..."
    #Ryukyu Validator
    ryukyu_validator = RyukyuHTMLValidator.new
    #W3C Validator
    w3c_validator = NuValidator.new(:validator_uri => 'https://validator.w3.org/nu/')
    #AChecker Validator
    achecker_validator = ACheckerValidator.new

    folders.each do |folder|
      Dir.glob(folder+"/**/*.html") do |file_name|
        if !self.ignore_file?(file_name, options)
          puts "  Checking #{file_name}"
          html_file = HTMLFile.new(file_name)
          @@all_html_files[file_name] = html_file

          if options[:validators] == nil or options[:validators].include?('ryukyu')
            ryukyu_validator.validate(html_file)
          end

          if options[:validators] == nil or options[:validators].include?('w3c')
            begin
              w3c_results = w3c_validator.validate_file(html_file.file_path)
              html_file.errors.concat(w3c_results.errors)
              html_file.warnings.concat(w3c_results.warnings)
            rescue
              html_file.errors.push(ValidationMessage.new("NA","W3C: service is down.",nil))
            end
          end

          if options[:validators] == nil or options[:validators].include?('achecker')
            results = achecker_validator.validate(html_file.file_path)
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
  
  def self.check_sass(folders, options)
    puts "Checking SASS..."
    #Ryukyu Validator
    ryukyu_validator = RyukyuSASSValidator.new

    folders.each do |folder|
      Dir.glob(folder+"/**/*.scss") do |file_name|
        if !self.ignore_file?(file_name, options)
          puts "  Checking #{file_name}"
          sass_file = SASSFile.new(file_name)
          @@all_sass_files << sass_file
          ryukyu_validator.validate(sass_file)
        end
      end     
    end

    return @@all_sass_files
  end

  def self.cross_check_html_sass(html_files,sass_files)
    ryukyu_validator = RyukyuCrossValidator.new
    puts "Performing cross validation between HTML and SASS..."
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
            path_components.each do |folder_name|
              return true if folder_name.match(/#{term}/)
            end
          elsif exclude_folder.match(/\*.*\w$/) #match back only
            term = exclude_folder.gsub(/\*/,'')
            path_components.each do |folder_name|
              return true if folder_name.match(/#{term}$/)
            end
          elsif exclude_folder.match(/.+\*$/) #match front only
            term = exclude_folder.gsub(/\*/,'')
            path_components.each do |folder_name|
              return true if folder_name.match(/^#{term}/)
            end            
          else #no wildcard, match exactly
            path_components.each do |folder_name|
              return true if folder_name == exclude_folder
            end            
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