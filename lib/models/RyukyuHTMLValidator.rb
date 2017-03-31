require_relative 'ValidationMessage.rb'

class RyukyuHTMLValidator
    def initialize

    end

    def validate(html_file)
        h1_tags = []

        html_file.root_tags.each do |root_tag|
            html_file.check_all_elements(root_tag) do |current_element|
                line_number = current_element.code_line.line_number
                line_str = current_element.code_line.str.chomp.strip

                #Insert custom checks here

                #1) Ryukyu coding rule, no <img /> style void tags
                if current_element.is_a?(HTMLTagVoid)

                    if current_element.str.match(/\w+\s+"/)
                        line_str = current_element.str.gsub(/(\w+)\s+"/,'\1' + " ".colorize(:background => :yellow) + '"')
                        html_file.warnings << ValidationMessage.new(line_number, "Ryukyu: No trailing white spaces at end of attribute value", line_str)
                    end

                    if current_element.str.match(/<\s*(\w+)\s*.*(\/\s*>)$/)
                        return if current_element.type == "path" #path is a foreign tag, allow "/" at the end
                        html_file.warnings << ValidationMessage.new(line_number, "Ryukyu: void tag should not have '/' at end", line_str)
                    end

                    #Already checked by W3C
                    if current_element.type == 'img'
                        if !current_element.str.match(/alt/)
                            html_file.warnings << ValidationMessage.new(line_number, "Ryukyu: img tag needs alt attribute defined", line_str)
                        end
                    end

                end

                #2) No half-width spaces in content
                if current_element.is_a?(HTMLContent)
                    asian_char_regex = /([\p{Han}|\p{Katakana}|\p{Hiragana}|\p{Hangul}])(\s+)/
                    if current_element.str.match(asian_char_regex)
                        line_str = current_element.str.gsub(asian_char_regex,'\1'+" ".colorize(:background => :yellow))
                        html_file.warnings << ValidationMessage.new(line_number, "Ryukyu: No half-width spaces in Japanese characters", line_str)
                    end
                end

                #3) Only one h1 tag
                if current_element.is_a?(HTMLTagOpen)
                    if current_element.str.match(/\w+\s+"/)
                        line_str = current_element.str.gsub(/(\w+)\s+"/,'\1' + " ".colorize(:background => :yellow) + '"')
                        html_file.warnings << ValidationMessage.new(line_number, "Ryukyu: No trailing white spaces at end of attribute value", line_str)
                    end

                    if current_element.str.match(/\s+>\s*$/)
                        line_str = current_element.str.gsub(/(\s+)(>\s*)$/," ".colorize(:background => :yellow) + '\2')
                        html_file.warnings << ValidationMessage.new(line_number, "Ryukyu: No trailing white spaces at end of tag >", line_str)                            
                    end

                    if current_element.closing_tag.str.match(/\s+>\s*$/)
                        line_str = current_element.closing_tag.str.gsub(/(\s+)(>\s*)$/," ".colorize(:background => :yellow) + '\2')
                        html_file.warnings << ValidationMessage.new(current_element.closing_tag.code_line.line_number, "Ryukyu: No trailing white spaces at end of tag >", line_str)
                    end

                    if current_element.type == 'h1'
                        h1_tags << current_element
                        if h1_tags.length > 1
                            html_file.warnings << ValidationMessage.new(line_number, "Ryukyu: We usually use h1 for logo or page title.  Only one h1 per document.", line_str)
                        end
                    elsif current_element.type == 'a'
                        if !current_element.str.match(/href/)
                            html_file.warnings << ValidationMessage.new(line_number, "Ryukyu: a tag needs href attribute defined", line_str)
                        end
                    end                    
                end

            end #end current_element
        end #end root_tag

        return html_file
    end #end def

end