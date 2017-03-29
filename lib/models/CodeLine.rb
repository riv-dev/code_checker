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

        begin
        #Overrid this method in child classes
        custom_initialize_instance_variables

        #Override this method in child classes
        custom_process_line(@str)
        rescue => e
            puts e
        end
    end

    #Override method
    def custom_initialize_instance_variables
        #override this method
        puts "[Application Error]".colorize(:color => :white, :background => :red) + " [#{__FILE__}][Need to override #{__method__} method in #{self.class} class]".red
        return false
    end

    #Override method
    def custom_process_line(str)
        puts "[Application Error]".colorize(:color => :white, :background => :red) + " [#{__FILE__}][Need to override #{__method__}  method in #{self.class} class]".red
        return false        
    end # end def

    def to_s
        @str
    end

end