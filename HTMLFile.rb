require_relative 'HTMLLine.rb'

class HTMLFile
    attr_accessor :file_path, :lines, :errors, :warnings

    def initialize(file_path)
        @errors = []
        @warnings = []
        @file_path = file_path
        @lines = []

        File.open(file_path, 'r') do |f|
            i = 1

            f.each_line do |line|
                @lines << HTMLLine.new(self, line, i)
                i = i + 1
            end #f.each_line
        end #File.open

        if @errors.length > 0 or @warnings.length > 0
            puts @file_path
            @errors.each do |error|
                puts "  #{error}"
            end

            @warnings.each do |warning|
                puts "  #{warning}"
            end
        end
    end #initialize

    def to_s
        @file_path
    end
end