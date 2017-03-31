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

        return response.body
    end

end