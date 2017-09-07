#encoding: utf-8
require 'json'

class JSONView 
    @@output = nil
    #def self.clear_output_file(output_file)
    #    return if output_file == nil
    #    f = File.open(output_file,'w')
    #    f.close
    #end
    @@all_results = []

    @@display_all_invoked = false

    def self.display(code_file)
        return if code_file == nil

        results = {:file_path => code_file.file_path, :errors => [], :warnings => [], :success => false}

        if code_file.errors.length > 0 or code_file.warnings.length > 0
            code_file.errors.each do |error|
                error_msg = error.message.gsub(/"/,"'")
                results[:errors] << {:line_num => error.line, :message => error_msg, :source => error.source}
            end

            code_file.warnings.each do |warning|
                warning_msg = warning.message.gsub(/"/,"'")
                results[:warnings] << {:line_num => warning.line, :message => warning_msg, :source => warning.source}
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

end