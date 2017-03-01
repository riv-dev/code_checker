require_relative 'HTMLTagOpen.rb'
require_relative 'HTMLTagClose.rb'

class HTMLLine
    attr_accessor :html_file
    attr_accessor :str
    attr_accessor :line_number
    attr_accessor :open_bracket_detected
    attr_accessor :tags #Type HTMLTag

    def initialize(html_file, line_str, line_number)
        @html_file = html_file
        @tags = []
        @open_bracket_detected = false
        @opening_tag_detected = false
        @closing_tag_detected = false
        @forward_slash_detected = false
        @str = line_str
        @line_number = line_number
        #puts "#{@line_number}: #{@str}"

        detect_tags(@str)

        puts "line #{@line_number}: #{@tags.length}"
    end

    def to_s
        @str
    end

    def puts_error(error, i)
        @html_file.errors << "[Error][#{error}]: line #{i}"
    end

    def puts_error_location(str, i)
        str = str.scan(/^.{#{i-1}}|.+/).join("*Error*")
        @html_file.errors << "  #{str}"
    end

    def puts_warning(warning, i)
        @html_file.warnings << "[Warning][#{warning}]: line #{i}"
    end

    def puts_warning_location(str, i)
        str = str.scan(/^.{#{i-1}}|.+/).join("*Warning*")
        @html_file.warnings << "  #{str}"
    end

    def detect_tags(str)
        #tags_arr = str.scan(/<.*?>/)

        #tags_arr.each do |tag_str|
        #    @tags << HTMLTag.new(tag_str)
        #end

        @open_bracket_detected = false;
        @current_tag_str = ""

        i = 1
        str.split("").each do |char|
            if char == "<" and !@open_bracket_detected
                @open_bracket_detected = true
                #new tag detected
                @current_tag_str = "<"
            elsif char == "<" and @open_bracket_detected
                #we have a syntax error
                puts_error("double '<'", @line_number)
                puts_error_location(str,i)
            elsif char == ">" and @open_bracket_detected and @forward_slash_detected
                #a closing tag has been detected
                @current_tag_str << ">"
                ##search for the opening tag and set the closing tag
                closing_tag = HTMLTagClose.new(self, @current_tag_str)
                closing_tag.opening_tag = nil #search for opening tag
                #go backwards with current tags array and match with first match
                @tags.reverse.each do |searched_tag|
                    if searched_tag.is_a?(HTMLTagOpen)
                        opening_tag = searched_tag #clarify
                        if opening_tag.type == closing_tag.type and !opening_tag.has_closing_tag
                            opening_tag.closing_tag = closing_tag
                            closing_tag.opening_tag = opening_tag
                            break
                        end #else continue to search for the opening tag in the next iteration
                    end #end if 
                end #end do
                
                #we have to back track and continue to find the opening tag
                if !closing_tag.has_opening_tag
                    @html_file.lines.reverse.each do |current_line|
                        current_line.tags.reverse.each do |searched_tag|
                            if searched_tag.is_a?(HTMLTagOpen)
                                opening_tag = searched_tag #clarify
                                if opening_tag.type == closing_tag.type and !opening_tag.has_closing_tag
                                    opening_tag.closing_tag = closing_tag
                                    closing_tag.opening_tag = opening_tag
                                    break
                                end #else continue to search for the opening tag in the next iteration
                            end #end if                             
                        end #end do  
                        break if closing_tag.has_opening_tag #else we have to continue to back track
                    end #end do
                end #end if

                if !closing_tag.has_opening_tag
                    puts_error("Closing tag has no opening tag", @line_number)
                    puts_error_location(str,i)                    
                end

                @tags << closing_tag
                @current_tag_str = ""
                @open_bracket_detected = false
                @forward_slash_detected = false
            elsif char == ">" and @open_bracket_detected and !@forward_slash_detected
                #opening tag has been detected
                @current_tag_str << ">"
                tag = HTMLTagOpen.new(self, @current_tag_str)
                #the closing tag should exist somewhere below
                @tags << tag
                @current_tag_str = ""
                @open_bracket_detected = false
            elsif char == ">" and !@open_bracket_detected
                #potential syntax error
                puts_warning("closing '>' detected without opening '<', check lines above", @line_number)
                puts_warning_location(str,i)
            elsif char == "/" and @open_bracket_detected
                @forward_slash_detected = true;
                @current_tag_str << char
            elsif char == "/" and !@open_bracket_detected
                #it is probably just regular inner HTML (content)
            elsif @open_bracket_detected
                @current_tag_str << char
            elsif !@open_bracket_detected
                #should be text within a tag
            else

            end #end if
            i = i + 1
        end #end do 

    end # end def
end