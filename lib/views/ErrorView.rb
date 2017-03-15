require 'colorize'

class ErrorView


    def initialize(code_file, output_file)
        if output_file
            @output = open(output_file,'a')
        end

        #Display errors
        puts_it "Checked #{code_file.file_path}"
        if code_file.errors.length > 0 or code_file.warnings.length > 0
            code_file.errors.each do |error|
                puts_it "  #{error}"
            end

            code_file.warnings.each do |warning|
                puts_it "  #{warning}"
            end
            puts_it " "
        else
            puts_it "  " + "[Success]".green + "[No errors found]"
            puts_it " "
        end
        puts_it " "

        @output.close if @output
    end    

    def puts_it(str)
        if @output
            #remove coloring
            str_nocolor = str.gsub(/\033\[\d+;\d+;\d+m(.*?)\033\[0m/,'\1')
            @output.write("#{str_nocolor}\n")
        end

        puts str
    end


end