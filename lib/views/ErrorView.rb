class ErrorView

    def initialize(code_file)
        #Display errors
        puts "Checked #{code_file.file_path}"
        if code_file.errors.length > 0 or code_file.warnings.length > 0
            code_file.errors.each do |error|
                puts "  #{error}"
            end

            code_file.warnings.each do |warning|
                puts "  #{warning}"
            end
            puts
        else
            puts "  " + "[Success]".green + "[No errors found]"
            puts
        end
        puts
    end    

end