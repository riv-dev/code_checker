require 'colorize'

class CodeLine
    attr_accessor :code_file
    attr_accessor :str
    attr_accessor :line_number

    def initialize(code_file, line_str, line_number)
        @code_file = code_file
        @str = line_str
        @line_number = line_number
        #puts "#{@line_number}: #{@str}"

        #Overrid this method in child classes
        custom_initialize_instance_variables

        #Override this method in child classes
        custom_process_line(@str)
    end

    #Override method
    def custom_initialize_instance_variables
        #override this method
        puts "[Application Error]".red + "[#{__FILE__}][Need to override #{__method__}]"
        return false
    end

    #Override method
    def custom_process_line(str)
        puts "[Application Error]".red + "[#{__FILE__}][Need to override #{__method__}]"
        return false        
    end # end def

    def to_s
        @str
    end

    def puts_error(error, i)
        @code_file.errors << "[Error]".colorize(:color => :white, :background => :red) + " line #{i}: " + "[#{error}]".red
    end

    def puts_error_location(str, i)
        str = str.scan(/^.{#{i-1}}|.+/).join("*Error*".red)
        @code_file.errors << "\n    #{str.strip}\n\n\n"
    end

    def puts_warning(warning, i)
        @code_file.warnings << "[Warning]".colorize(:color => :white, :background => :yellow) + " line #{i}: " + "[#{warning}]".yellow
    end

    def puts_warning_location(str, i)
        str = str.scan(/^.{#{i-1}}|.+/).join("*Warning*".yellow)
        @code_file.warnings << "\n    #{str.strip}\n\n\n"
    end

end