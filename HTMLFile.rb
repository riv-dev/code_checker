require_relative 'HTMLLine.rb'

class HTMLFile
    attr_accessor :file_path, :lines, :errors, :warnings

    def check_all_tags
        @lines.each do |current_line|
            current_line.tags.each do |current_tag|
                yield(current_line, current_tag)
            end
        end    
    end

    def puts_error(error, line)
        @errors << "[Error][#{error}]: line #{line.line_number}"
        @errors << "  #{line.str.strip}"
    end

    def puts_warning(warning, line)
        @warnings << "[Warning][#{warning}]: line #{line.line_number}"
        @warnings << "  #{line.str.strip}"
    end

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

            #Insert all custom checks here
            check_all_tags do |current_line, current_tag|
                if current_tag.is_a?(HTMLTagOpen) and !current_tag.has_closing_tag
                    puts_error("#{current_tag.str} has no closing tag", current_line)
                end                
            end

        end #File.open

        #Display errors
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