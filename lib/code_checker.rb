require_relative 'models/HTMLFile.rb'

class CodeChecker

  def self.hi
    puts "Hello World!"
  end

  def self.check(html_file)
    HTMLFile.new(html_file)
  end

  def self.check_folder(html_folder)
    Dir.glob(html_folder+"/**/*.html") do |my_html_file| # note one extra "*"
      HTMLFile.new(my_html_file)
    end

    Dir.glob(html_folder+"/**/*.hbs") do |my_hbs_file| # note one extra "*"
      HTMLFile.new(my_hbs_file)
    end

    Dir.glob(html_folder+"/**/*.php") do |my_php_file| # note one extra "*"
      HTMLFile.new(my_php_file)
    end    
  end
end