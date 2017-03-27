require 'colorize'

class ErrorView
    @@output = nil

    def self.display_w3c(uri, results, output_file)
        if output_file
            @@output = open(output_file,'a')
        end

        self.puts_it "Checked #{uri}"

        #Display errors
        #self.puts_it "Checked #{code_file.file_path}"
        if results.errors.length > 0 or results.warnings.length > 0
            results.errors.each do |error|
                self.puts_error(error.message,error.line,error.source)    
            end

            results.warnings.each do |warning|
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

    def self.puts_error(error, line, details)
        self.puts_it "[Error]".colorize(:color => :white, :background => :red) + " line #{line}: " + "[#{error}]".red
        self.puts_it "\n    #{details}\n\n\n"
    end

    def self.puts_warning(warning, line, details)
        self.puts_it "[Warning]".colorize(:color => :black, :background => :yellow) + " line #{line}: " + "[#{warning}]".yellow
        self.puts_it "\n    #{details}\n\n\n"
    end

    def self.display(code_file, output_file)
        if output_file
            @@output = open(output_file,'a')
        end

        #Display errors
        self.puts_it "Checked #{code_file.file_path}"
        if code_file.errors.length > 0 or code_file.warnings.length > 0
            code_file.errors.each do |error|
                self.puts_it "  #{error}"
            end

            code_file.warnings.each do |warning|
                self.puts_it "  #{warning}"
            end
            self.puts_it " "
        else
            self.puts_it "  " + "[Success]".green + "[No errors found]"
            self.puts_it " "
        end
        self.puts_it " "

        @@output.close if @@output
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