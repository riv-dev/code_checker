require_relative 'models/HTMLFile.rb'

class CodeChecker

  def self.hi
    puts "Hello World!"
  end

  def self.check(html_file)
    HTMLFile.new(html_file)
  end

  def self.ignore_file?(path)
    path_components = path.split("/");
    filename = path_components.last

    #puts "Checking ignore path: #{path}"
    #puts "  filename: #{filename}"

    if @@exclude_files != nil
      @@exclude_files.each do |exclude_file|

        if exclude_file.match(/\*.+\*/) #match front and back
          term = exclude_file.gsub(/\*/,'')
          return true if filename.match(/#{term}/)
        elsif exclude_file.match(/\*.*\w$/) #match back only
          term = exclude_file.gsub(/\*/,'')
          return true if filename.match(/#{term}$/)
        elsif exclude_file.match(/.+\*$/) #match front only
          term = exclude_file.gsub(/\*/,'')
          return true if filename.match(/^#{term}/)
        else
          return true if filename == exclude_file
        end
      end  
    end

    path_components.pop #pop off the filename, leave the folder path only

    if @@exclude_folders != nil
      @@exclude_folders.each do |exclude_folder|
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
          else
            path_components.each do |folder_name|
              return true if folder_name == exclude_folder
            end            
          end
      end
    end

    return false
  end

  def self.check_folder(html_folder, options)
    check_all = false
    check_all = true if options[:types] == nil or options[:types].length == 0
    types = options[:types]
    @@exclude_files = options[:exclude_files]
    @@exclude_folders = options[:exclude_folders]

    if check_all or types.include?('html') 
      puts "Checking html files"
      puts
      Dir.glob(html_folder+"/**/*.html") do |my_html_file| # note one extra "*"
        HTMLFile.new(my_html_file) if !self.ignore_file?(my_html_file)
      end
    end

    if check_all or types.include?('hbs')
      puts "Checking hbs files"
      puts
      Dir.glob(html_folder+"/**/*.hbs") do |my_hbs_file| # note one extra "*"
        HTMLFile.new(my_hbs_file) if !self.ignore_file?(my_hbs_file)
      end
    end

    if check_all or types.include?('php')
      puts "Checking php files"
      puts
      Dir.glob(html_folder+"/**/*.php") do |my_php_file| # note one extra "*"
        HTMLFile.new(my_php_file) if !self.ignore_file?(my_php_file)
      end    
    end

    if check_all or types.include?('ejs')
      puts "Checking ejs files"
      puts
      Dir.glob(html_folder+"/**/*.ejs") do |my_ejs_file| # note one extra "*"
        HTMLFile.new(my_ejs_file) if !self.ignore_file?(my_ejs_file)
      end    
    end

  end
end