require_relative 'CodeLine.rb'

class CodeFile
    attr_accessor :file_path, :lines, :errors, :warnings

    def initialize(file_path)
        @errors = []
        @warnings = []
        @file_path = file_path
        @lines = []

        #must override this method
        custom_set_codeline_class

        #override this method
        custom_initialize_instance_variables

        #insert read_file_and_check_process_line here in child
        read_file_and_process_each_line

        #override this method
        custom_check_file_after_processing_done

        #insert display_all_errors_and_warnings here in child
        display_all_errors_and_warnings


    end #initialize


    protected
    def custom_set_codeline_class
        @codeline_class = CodeLine.class
        puts "[Application Error]".red + "[#{__FILE__}][Need to override #{__method__}]"
        return false
    end

    def custom_initialize_instance_variables
        #override this method
        puts "[Application Error]".red + "[#{__FILE__}][Need to override #{__method__}]"
        return false
    end
    
    def custom_check_file_after_processing_done
        #override this method
        puts "[Application Error]".red + "[#{__FILE__}][Need to override #{__method__}]"
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

    def display_all_errors_and_warnings
        #Display errors
        puts "Checked #{@file_path}"
        if @errors.length > 0 or @warnings.length > 0
            @errors.each do |error|
                puts "  #{error}"
            end

            @warnings.each do |warning|
                puts "  #{warning}"
            end
            puts
        else
            puts "  " + "[Success]".green + "[No errors found]"
            puts
        end
        puts
    end

    def puts_error(error, line, details)
        @errors << "[Error]".colorize(:color => :white, :background => :red) + " line #{line.line_number}: " + "[#{error}]".red
        @errors << "\n    #{details}\n\n\n"
    end

    def puts_warning(warning, line, details)
        @warnings << "[Warning]".colorize(:color => :black, :background => :yellow) + " line #{line.line_number}: " + "[#{warning}]".yellow
        @warnings << "\n    #{details}\n\n\n"
    end

end