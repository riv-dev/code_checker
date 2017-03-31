require_relative 'CodeLine.rb'

class CodeFile
    attr_accessor :file_path, :lines, :errors, :warnings, :reports

    #Used for parsing document
    attr_accessor :open_comment_detected

    def initialize(file_path)
        @errors = []
        @warnings = []
        @reports = {}
        @file_path = file_path
        @lines = []

        @open_comment_detected = false

        begin
        #must override this method
        custom_set_codeline_class

        #override this method
        custom_initialize_instance_variables

        #insert read_file_and_check_process_line here in child
        read_file_and_process_each_line

        #Refactored to views
        #insert display_all_errors_and_warnings here in child
        #display_all_errors_and_warnings
        rescue => e
            puts e
        end


    end #initialize

    protected
    #Override this method in the child class
    def custom_set_codeline_class
        @codeline_class = CodeLine
        puts "[Application Error]".colorize(:color => :white, :background => :red) + " [#{__FILE__}][Need to override #{__method__} method in #{self.class} class]".red
        return false
    end

    #Override this method in the child class
    def custom_initialize_instance_variables
        puts "[Application Error]".colorize(:color => :white, :background => :red) + " [#{__FILE__}][Need to override #{__method__} method in #{self.class} class]".red
        return false
    end
    
    def to_s
        return @file_path
    end

    def read_file_and_process_each_line
        #Open the HTML file and read in each line
        File.open(file_path, 'r') do |f|
            line_number = 1

            f.each_line do |line|
                #Custom process line code
                @lines << @codeline_class.new(self, line, line_number)

                line_number = line_number + 1
            end #f.each_line

        end #File.open
    end

end