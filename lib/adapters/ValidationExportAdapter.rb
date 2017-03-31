class ValidationExportAdapter

    @@output = nil

    def self.export_result(code_file, output_folder)
        return if code_file == nil

        code_file.reports.keys.each do |report_type|
            filename = report_type.to_s + "_" + code_file.file_path.split("/").last
            export_report_path = output_folder + "/reports/" + File.dirname(code_file.file_path).gsub(output_folder+"/imported/",'') + "/" + filename
            puts "Exported #{report_type.to_s} detailed report to: #{export_report_path}"

            dirname = File.dirname(export_report_path)

            unless File.directory?(dirname)
                FileUtils.mkdir_p(dirname)
            end

            a = File.open(export_report_path,'w')
            a << code_file.reports[report_type]
            a.close
        end

        unless File.directory?(output_folder)
            FileUtils.mkdir_p(output_folder)
        end

        @@output = open(output_folder + "/results.txt",'a')

        self.puts_it "####################################################################################"
        self.puts_it "Checked #{code_file.file_path}"
        self.puts_it "####################################################################################\n\n"

        #Display errors
        #self.puts_it "Checked #{code_file.file_path}"
        if code_file.errors.length > 0 or code_file.warnings.length > 0
            code_file.errors.each do |error|
                error_msg = "W3C: " + error.message if error.is_a?(W3CValidators::Message)
                error_msg = error.message unless error_msg
                self.puts_error(error_msg,error.line,error.source)    
            end

            code_file.warnings.each do |warning|
                warning_msg = "W3C: " + warning.message if warning.is_a?(W3CValidators::Message)
                warning_msg = warning.message unless warning_msg
                self.puts_warning(warning_msg,warning.line,warning.source)
            end
            self.puts_it " "
        else
            self.puts_it "  " + "[Success]".green + "[No errors found]"
            self.puts_it " "
        end
        self.puts_it " "

        @@output.close if @@output    
    end

    def self.export_all_results(code_files, output_folder)
        return if code_files == nil
        puts "Exported results to: #{output_folder}/results.txt"

        if code_files.respond_to?('keys')
            code_files.keys.each do |filename|
                self.export_result(code_files[filename], output_folder)
             end
        else
            code_files.each do |code_file|
                self.export_result(code_file, output_folder)
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
        #remove coloring
        str_nocolor = str.gsub(/\033\[\d+;\d+;\d+m(.*?)\033\[0m/,'\1')
        @@output.write("#{str_nocolor}\n")
    end

end