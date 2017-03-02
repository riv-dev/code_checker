require_relative 'models/HTMLFile.rb'

class CodeChecker

  def self.hi
    puts "Hello World!"
  end

  def self.check(html_file)
    HTMLFile.new(html_file)
  end

end