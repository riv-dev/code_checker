#encoding: utf-8
require 'json'

class JSONView 
    @@all_results = []

    @@display_all_invoked = false
    def self.message_type(validation_message)
        if validation_message.is_a?(W3CValidators::Message)
            return "W3C"
        elsif validation_message.message.match(/Ryukyu/)
            return "Ryukyu"
        elsif validation_message.message.match(/AChecker/)
            return "AChecker"
        end
    end

    def self.display(code_file)
        return if code_file == nil

        file_type = nil
        if code_file.is_a?(HTMLFile)
            file_type = "html"
        elsif code_file.is_a?(SASSFile)
            file_type = "sass"
        end

        results = {version: "2.0.0", :file_path => code_file.file_path, :file_type => file_type, :errors => [], :warnings => [], :success => false}

        if code_file.errors.length > 0 or code_file.warnings.length > 0
            code_file.errors.each do |error|
                error_msg = error.message.gsub(/"/,"'")
                type = self.message_type(error)
                results[:errors] << {:validator => type, :line_num => error.line, :message => error_msg, :source => error.source}
            end

            code_file.warnings.each do |warning|
                warning_msg = warning.message.gsub(/"/,"'")
                type = self.message_type(warning)
                results[:warnings] << {:validator => type, :line_num => warning.line, :message => warning_msg, :source => warning.source}
            end
        else
            results[:success] = true
        end

        if @@display_all_invoked
            @@all_results << results
        else
            puts JSON.pretty_generate(results)
        end
    end

    def self.display_all(code_files)
        @@all_results = []

        @@display_all_invoked = true
        return if code_files == nil

        if code_files.respond_to?('keys')
            code_files.keys.each do |filename|
                self.display(code_files[filename])
             end
        else
            code_files.each do |code_file|
                self.display(code_file)
            end
        end

        puts JSON.pretty_generate(@@all_results)

        @@display_all_invoked = false
    end

    def self.display_all_html_and_sass(html_files, sass_files)
        @@all_results = []
        
        @@display_all_invoked = true
        return if html_files == nil or sass_files == nil
        
        html_files.keys.each do |filename|
            self.display(html_files[filename])
        end

        sass_files.each do |sass_file|
            self.display(sass_file)
        end
        
        puts JSON.pretty_generate(@@all_results)
        
        @@display_all_invoked = false
    end
end