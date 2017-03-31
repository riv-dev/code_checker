require 'net/http'
require 'uri'
require 'nokogiri'

class ACheckerValidator

    def initialize
        @api_uri = URI.parse("https://achecker.ca/checker/index.php")
    end

    def validate(file_path)
        html_str = File.read(file_path)

        form_data = {
            'pastehtml' => html_str,
            'validate_paste' => 'Check It',
            'radio_gid[]' => '8',
            'rpt_format' => '1'
        }

        response = Net::HTTP.post_form(@api_uri, form_data)

        #Parse response with Nokogiri
        errors = []
        warnings = []

        page = Nokogiri::HTML(response.body)
        unparsed_errors = page.css('#AC_errors .gd_one_check')
        unparsed_errors.each do |unparsed_error|
            error_msg = unparsed_error.css('.gd_msg a').text.chomp.strip
            error_fix = unparsed_error.css('.gd_question_section').text.chomp.strip
            error_message_full = error_msg + " " + error_fix

            unparsed_error.css('table tr').each do |unparsed_error_row|
                captures = unparsed_error_row.text.match(/Line\s+(\d+)/)
                line_number = captures[1] if captures
                line_str = unparsed_error_row.css('pre').text.chomp.strip

                errors << ValidationMessage.new(line_number, "AChecker: #{error_message_full}", line_str)
            end
        end


        results = {
            :report => response.body, #Raw HTML
            :errors => errors, #Parsed errors
            :warnings => warnings #Parsed warnings
        }

        return results
    end

end