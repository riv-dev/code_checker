#encoding: utf-8
require 'colorize'
require_relative 'CodeLine.rb'
require_relative 'HTMLTagFactory.rb'
require_relative 'HTMLContent.rb'
require_relative 'ValidationMessage.rb'

class HTMLLine < CodeLine
    attr_accessor :tags #Type HTMLTag
    @@current_tag_str = ""
    @@current_content_str = ""
    @@current_content_start_line = nil

    def initialize(code_file, line_str, line_number)
        super(code_file, line_str, line_number)
    end    

    #Override method
    def custom_initialize_instance_variables
        @tags = []
    end

    #Override method
    def custom_process_line(str)
        #ignore line
        if str.match(/<\s*!DOCTYPE\s+html\s*>/) #special HTML open tag
            return @tags = []
        end

        #Process the line through templating engine
        str = @code_file.process_line_through_templating_engine(str)

        #remove comments <!-- -->
        if @code_file.open_comment_detected and str.gsub!(/.*?-->/, ' ')
            #puts "end of comment"
            #puts "  #{str}"
            @code_file.open_comment_detected = false
        elsif @code_file.open_comment_detected
            #puts "comment ignored"
            #puts "  #{str}"
            return @tags = [] #commented line, don't process
        elsif str.gsub!(/<!--.*?-->/, ' ')
            #puts "comment removed"
            #puts " #{str}"
            @code_file.open_comment_detected = false
        elsif str.gsub!(/<!--.*/, ' ')
            #puts "open comment detected line:#{@line_number}}"
            #puts "  #{str}"
            @code_file.open_comment_detected = true
        end

        #remove scripts
        if @code_file.open_script_detected and str.gsub!(/<\s*\/\s*script\s*>/, ' ')
            #puts "end of script"
            #puts "  #{str}"
            @code_file.open_script_detected = false
        elsif @code_file.open_script_detected
            #puts "ignore script line"
            #puts "  #{str}"
            return @tags = []
        elsif str.gsub!(/<\s*script\s*.*>.*<\s*\/\s*script\s*>/, ' ')
            #puts "script removed"
            #puts " #{str}"
            @code_file.open_script_detected = false
        elsif str.gsub!(/<\s*script\s*.*>.*/, ' ')
            #puts "open script detected"
            #puts " #{str}"
            @code_file.open_script_detected = true
        end

        i = 1
        str.split("").each do |char|
            if char == "=" and @code_file.open_bracket_detected
                @code_file.open_attribute_detected = true
                @@current_tag_str << char
            elsif @code_file.open_attribute_detected and !@code_file.open_attribute_quote_detected and char == '"' or char == "'"
                @code_file.open_attribute_quote_detected = true
                @@current_tag_str << char
            elsif @code_file.open_attribute_detected and @code_file.open_attribute_quote_detected and char == '"' or char == "'"
                #a full attribute key=value pair has been detected
                @@current_tag_str << char
                @code_file.open_attribute_detected = false
                @code_file.open_attribute_quote_detected = false
            elsif char == "<" and !@code_file.open_bracket_detected
                @code_file.open_bracket_detected = true
                #new tag detected
                @@current_tag_str = "<"


            elsif char == ">" and @code_file.open_bracket_detected
                #a tag has been detected
                @@current_tag_str << ">"
                tag = HTMLTagFactory.create(self, @@current_tag_str)

                if tag != nil
                    @tags << tag
                else
                    @code_file.errors << ValidationMessage.new(@line_number, "invalid tag detected", str)
                end

                #Flush any current content into the current parent tag
                if @@current_content_str.strip.length > 0 and !@@current_content_str.match(/^\s+$/) and @code_file.parent_tags_stash.last != nil
                    @code_file.parent_tags_stash.last.children << HTMLContent.new(@@current_content_start_line, @@current_content_str.strip)
                    @@current_content_str = ""
                    @@current_content_start_line = nil
                end

                if tag.is_a?(HTMLTagOpen)
                    tag.parent = @code_file.parent_tags_stash.last
                    @code_file.parent_tags_stash.last.children << tag if @code_file.parent_tags_stash.last != nil
                    @code_file.parent_tags_stash.push(tag)
                    @code_file.opening_tag_detected = true
                elsif tag.is_a?(HTMLTagVoid)
                    tag.parent = @code_file.parent_tags_stash.last
                    @code_file.parent_tags_stash.last.children << tag if @code_file.parent_tags_stash.last != nil
                    #Void tag cannot be the parent of any other tag, do not push onto parent_tags_stash
                elsif tag.is_a?(HTMLTagClose) #search for opening tag
                    @code_file.opening_tag_detected = false
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
                        @code_file.lines.reverse.each do |current_line|
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
                        @code_file.errors << ValidationMessage.new(@line_number, "Closing tag has no opening tag", str)
                    else #end !closing_tag.has_opening_tag 
                        #pop the parent off
                        parent = @code_file.parent_tags_stash.pop 
                        #save root tags for future traversal.
                        #usually there is only one root tag, the <html> tag
                        @code_file.root_tags << parent if @code_file.parent_tags_stash.length == 0
                    end
                end #end if is_a?(HTMLTagClose)

                @@current_tag_str = ""
                @code_file.open_bracket_detected = false
            #elsif char == ">" and !@code_file.open_bracket_detected
            #    #potential syntax error
            #    puts_warning("closing '>' detected without opening '<', check lines above", @line_number)
            #    puts_warning_location(str,i)
            elsif @code_file.open_bracket_detected
                if char != "\r" and char != "\n"
                    @@current_tag_str << char
                end
            elsif !@code_file.open_bracket_detected and @code_file.opening_tag_detected
                #need to save the current line the content started one
                #because content can span multiple lines
                if char != "\r" and char != "\n"
                    if @@current_content_start_line == nil
                        @@current_content_start_line = self if char != " " and char != "\t"
                    end
                    @@current_content_str << char
                end
                #should be text within a tag
            else

            end #end if
            i = i + 1
        end #end do 

    end # end def

end