require_relative 'HTMLTagFactory.rb'
require_relative 'HTMLContent.rb'

class HTMLLine
    attr_accessor :html_file
    attr_accessor :str
    attr_accessor :line_number
    attr_accessor :tags #Type HTMLTag
    @@current_tag_str = ""
    @@current_content_str = ""

    def initialize(html_file, line_str, line_number)
        @html_file = html_file
        @tags = []
        @str = line_str
        @line_number = line_number
        #puts "#{@line_number}: #{@str}"

        detect_tags(@str)

        #puts "line #{@line_number}: #{@tags.length}"
    end

    def to_s
        @str
    end

    def puts_error(error, i)
        @html_file.errors << "[Error] line #{i}: [#{error}]"
    end

    def puts_error_location(str, i)
        str = str.scan(/^.{#{i-1}}|.+/).join("*Error*")
        @html_file.errors << "  #{str.strip}\n\n"
    end

    def puts_warning(warning, i)
        @html_file.warnings << "[Warning] line #{i}: [#{warning}]"
    end

    def puts_warning_location(str, i)
        str = str.scan(/^.{#{i-1}}|.+/).join("*Warning*")
        @html_file.warnings << "  #{str.strip}\n\n"
    end

    def detect_tags(str)
        #ignore line
        if str.match(/<\s*!DOCTYPE\s+html\s*>/) #special HTML open tag
            return @tags = []
        end

        #Process the line through templating engine
        str = @html_file.process_line_through_templating_engine(str)

        #remove comments <!-- -->
        if @html_file.open_comment_detected and str.gsub!(/.*?-->/, ' ')
            #puts "end of comment"
            #puts "  #{str}"
            @html_file.open_comment_detected = false
        elsif @html_file.open_comment_detected
            #puts "comment ignored"
            #puts "  #{str}"
            return @tags = [] #commented line, don't process
        elsif str.gsub!(/<!--.*?-->/, ' ')
            #puts "comment removed"
            #puts " #{str}"
            @html_file.open_comment_detected = false
        elsif str.gsub!(/<!--.*/, ' ')
            #puts "open comment detected line:#{@line_number}}"
            #puts "  #{str}"
            @html_file.open_comment_detected = true
        end

        #remove scripts
        if @html_file.open_script_detected and str.gsub!(/<\s*\/\s*script\s*>/, ' ')
            #puts "end of script"
            #puts "  #{str}"
            @html_file.open_script_detected = false
        elsif @html_file.open_script_detected
            #puts "ignore script line"
            #puts "  #{str}"
            return @tags = []
        elsif str.gsub!(/<\s*script\s*.*>.*<\s*\/\s*script\s*>/, ' ')
            #puts "script removed"
            #puts " #{str}"
            @html_file.open_script_detected = false
        elsif str.gsub!(/<\s*script\s*.*>.*/, ' ')
            #puts "open script detected"
            #puts " #{str}"
            @html_file.open_script_detected = true
        end

        i = 1
        str.split("").each do |char|
            if char == "=" and @html_file.open_bracket_detected
                @html_file.open_attribute_detected = true
                @@current_tag_str << char
            elsif @html_file.open_attribute_detected and !@html_file.open_attribute_quote_detected and char == '"' or char == "'"
                @html_file.open_attribute_quote_detected = true
                @@current_tag_str << char
            elsif @html_file.open_attribute_detected and @html_file.open_attribute_quote_detected and char == '"' or char == "'"
                #a full attribute key=value pair has been detected
                @@current_tag_str << char
                @html_file.open_attribute_detected = false
                @html_file.open_attribute_quote_detected = false
            elsif char == "<" and !@html_file.open_bracket_detected
                @html_file.open_bracket_detected = true
                #new tag detected
                @@current_tag_str = "<"


            elsif char == ">" and @html_file.open_bracket_detected
                #a tag has been detected
                @@current_tag_str << ">"
                tag = HTMLTagFactory.create(self, @@current_tag_str)

                if tag != nil
                    @tags << tag
                else
                    puts_error("invalid tag detected", @line_number)
                    puts_error_location(str,i)
                end

                #Flush any current content into the current parent tag
                if @@current_content_str.length > 0 and @html_file.parent_tags_stash.last != nil
                    @html_file.parent_tags_stash.last.children << HTMLContent.new(self, @@current_content_str.strip)
                    @@current_content_str = ""
                end

                if tag.is_a?(HTMLTagOpen)
                    tag.parent = @html_file.parent_tags_stash.last
                    @html_file.parent_tags_stash.last.children << tag if @html_file.parent_tags_stash.last != nil
                    @html_file.parent_tags_stash.push(tag)
                    @html_file.opening_tag_detected = true
                elsif tag.is_a?(HTMLTagVoid)
                    tag.parent = @html_file.parent_tags_stash.last
                    @html_file.parent_tags_stash.last.children << tag if @html_file.parent_tags_stash.last != nil
                    #Void tag cannot be the parent of any other tag, do not push onto parent_tags_stash
                elsif tag.is_a?(HTMLTagClose) #search for opening tag
                    @html_file.opening_tag_detected = false
                    closing_tag = tag #clarify
                   
                    #go backwards with current tags array and match with first match
                    @tags.reverse.each do |searched_tag|
                        if searched_tag.is_a?(HTMLTagOpen)
                            opening_tag = searched_tag #clarify
                            if opening_tag.type == closing_tag.type and !opening_tag.has_closing_tag
                                opening_tag.closing_tag = closing_tag
                                closing_tag.opening_tag = opening_tag
                                break
                            end #else continue to search for the opening tag in the next iteration
                        end #end if searched_tag.is_a?(HTMLTagOpen)
                    end #end do |searched_tag|
                    
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
                                end #end if searched_tag.is_a?(HTMLTagOpen)                             
                            end #end do |searched_tag|  
                            break if closing_tag.has_opening_tag #else we have to continue to back track
                        end #end do |current_line|
                    end #end !closing_tag.has_opening_ta

                    if !closing_tag.has_opening_tag
                        puts_error("Closing tag has no opening tag", @line_number)
                        puts_error_location(str,i)                    
                    else #end !closing_tag.has_opening_tag 
                        #pop the parent off
                        parent = @html_file.parent_tags_stash.pop 
                        #save root tags for future traversal.
                        #usually there is only one root tag, the <html> tag
                        @html_file.root_tags << parent if @html_file.parent_tags_stash.length == 0
                    end
                end #end if is_a?(HTMLTagClose)

                @@current_tag_str = ""
                @html_file.open_bracket_detected = false
            #elsif char == ">" and !@html_file.open_bracket_detected
            #    #potential syntax error
            #    puts_warning("closing '>' detected without opening '<', check lines above", @line_number)
            #    puts_warning_location(str,i)
            elsif @html_file.open_bracket_detected
                if char != "\r" and char != "\n"
                    @@current_tag_str << char
                end
            elsif !@html_file.open_bracket_detected and @html_file.opening_tag_detected
                if char != "\r" and char != "\n"
                    @@current_content_str << char
                end
                #should be text within a tag
            else

            end #end if
            i = i + 1
        end #end do 

    end # end def

end