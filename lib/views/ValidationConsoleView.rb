require 'colorize'

class ValidationConsoleView
    @@output = nil
    def self.clear_output_file(output_file)
        return if output_file == nil
        f = File.open(output_file,'w')
        f.close
    end

    def self.display(code_file, output_file)
        return if code_file == nil

        if output_file
            @@output = open(output_file,'a')
        end

        self.puts_it "Checked #{code_file.file_path}"

        #Display errors
        #self.puts_it "Checked #{code_file.file_path}"
        if code_file.errors.length > 0 or code_file.warnings.length > 0
            code_file.errors.each do |error|
                error.message = "W3C: " + error.message if error.is_a?(W3CValidators::Message)
                self.puts_error(error.message,error.line,error.source)    
            end

            code_file.warnings.each do |warning|
                warning.message = "W3C: " + warning.message if warning.is_a?(W3CValidators::Message)
                self.puts_warning(warning.message,warning.line,warning.source)
            end
            self.puts_it " "
        else
            self.puts_it "  " + "[Success]".green + "[No errors found]"
            self.puts_it " "
        end
        self.puts_it " "

        @@output.close if @@output    
    end

    def self.display_all(code_files, output_file)
        return if code_files == nil

        if code_files.respond_to?('keys')
            code_files.keys.each do |filename|
                self.display(code_files[filename], output_file)
             end
        else
            code_files.each do |code_file|
                self.display(code_file, output_file)
            end
        end
    end

    def self.puts_error(error, line, details)
        self.puts_it "[Error]".colorize(:color => :white, :background => :red) + " line #{line}: " + "[#{error}]".red
        self.puts_it "\n    #{details}\n\n\n"
    end

    def self.puts_warning(warning, line, details)
        self.puts_it "[Warning]".colorize(:color => :black, :background => :yellow) + " line #{line}: " + "[#{warning}]".yellow
        self.puts_it "\n    #{details}\n\n\n"
    end

    def self.puts_it(str)
        if @@output
            #remove coloring
            str_nocolor = str.gsub(/\033\[\d+;\d+;\d+m(.*?)\033\[0m/,'\1')
            @@output.write("#{str_nocolor}\n")
        end

        puts str
    end

end