require_relative 'models/HTMLFile.rb'

class CodeChecker

  def self.hi
    puts "Hello World!"
  end

  def self.check(html_file)
    HTMLFile.new(html_file)
  end

  def self.check_folder(html_folder,types)
    check_all = false
    check_all = true if types == nil

    if check_all or types.include?('html') 
      puts "Checking html files"
      Dir.glob(html_folder+"/**/*.html") do |my_html_file| # note one extra "*"
        HTMLFile.new(my_html_file)
      end
    end

    if check_all or types.include?('hbs')
      puts "Checking hbs files"
      Dir.glob(html_folder+"/**/*.hbs") do |my_hbs_file| # note one extra "*"
        HTMLFile.new(my_hbs_file)
      end
    end

    if check_all or types.include?('php')
      puts "Checking php files"
      Dir.glob(html_folder+"/**/*.php") do |my_php_file| # note one extra "*"
        HTMLFile.new(my_php_file)
      end    
    end

  end
end