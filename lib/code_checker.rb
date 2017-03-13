require_relative 'models/HTMLFile.rb'
require_relative 'models/HTMLFileFactory.rb'
require_relative 'models/SASSFile.rb'

class CodeChecker

  def self.hi
    puts "Hello World!"
  end

  #Run code checker on a specific file
  def self.check(file_path)
    begin
      captures = file_path.match(/\.(\w+)$/).captures
      if(captures[0] == 'scss')
        SASSFile.new(file_path)
      else
        HTMLFileFactory.create(html_file, captures[0])
      end
    rescue
      HTMLFile.new(file_path)
    end
  end

  #Run code checker on files within the folder
  def self.check_folder(html_folder, options)
    #Process options
    #By default check all types
    types = HTMLFileFactory.get_supported_types
    #if types option is defined, check only the specified types
    types = options[:types] if options[:types] != nil and options[:types].length > 0

    #import file and folder exclusion options
    @@exclude_files = options[:exclude_files]
    @@exclude_folders = options[:exclude_folders]

    #Run the checker for files and folders that have not been excluded
    types.each do |file_type|
      puts "Checking #{file_type} files"
      puts

      Dir.glob(html_folder+"/**/*.#{file_type}") do |file_name|
        HTMLFileFactory.create(file_name, file_type) if !self.ignore_file?(file_name)
      end 
    end #type.each do

    #Check SASS Files
    Dir.glob(html_folder+"/**/*.scss") do |file_name|
      SASSFile.new(file_name) if !self.ignore_file?(file_name)
    end     

  end #def self.check_folder

  private
  #Helper functions
  #Returns true if options have been set to ignore the file
  def self.ignore_file?(path)
    path_components = path.split("/");
    filename = path_components.last

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

end