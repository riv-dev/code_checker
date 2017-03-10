require 'colorize'
require_relative 'HTMLLine.rb'

class HTMLFile < CodeFile
    attr_accessor :file_path, :lines, :errors, :warnings

    #Root tags are used for searching the document
    attr_accessor :root_tags

    #Used for parsing the document
    attr_accessor :open_comment_detected, 
                  :open_bracket_detected, 
                  :opening_tag_detected, 
                  :closing_tag_detected, 
                  :open_script_detected, 
                  :open_attribute_detected, 
                  :open_attribute_quote_detected,
                  :parent_tags_stash


    def initialize(file_path)
        @errors = []
        @warnings = []
        @file_path = file_path
        @lines = []
        @root_tags = []

        #Attributes used for parsing the document
        @open_comment_detected = false
        @open_bracket_detected = false
        @opening_tag_detected = false
        @closing_tag_detected = false
        @open_script_detected = false
        @open_attribute_detected = false
        @open_attribute_quote_detected = false
        @parent_tags_stash = []

        @tags_by_id = {}
        @tags_by_class = {}

        #Open the HTML file and read in each line
        File.open(file_path, 'r') do |f|
            i = 1

            f.each_line do |line|
                #Process the HTML line and save it
                @lines << HTMLLine.new(self, line, i)
                i = i + 1
            end #f.each_line

        end #File.open

        if @root_tags.length == 0
            #Somewhere there was not a closing tag so the root was not 
            #discovered properly.  Manually add in the root
           @root_tags << @parent_tags_stash.first
        end

        #@root_tags.each do |root_tag|
        #    puts "Root tag: #{root_tag}"
        #    print_elements(root_tag,"")
        #    puts
        #end

        #At this point all HTML lines have been processed.
        #You may now iterate through the tags and look for errors or warnings
        #There should be only one root tag, the <html> tag, however allow cases where
        #there may be more than one root tag
        @root_tags.each do |root_tag|
            check_all_elements(root_tag) do |current_element|

                #Insert custom checks here

                #1) Ryukyu coding rule, no <img /> style void tags
                if current_element.is_a?(HTMLTagVoid)
                    if current_element.str.match(/<\s*(\w+)\s*.*(\/\s*>)$/)
                        puts_warning("Ryukyu: void tag should not have '/' at end", current_element.html_line, current_element.html_line.str.strip)
                    end
                end

                #2) No half-width spaces in content
                if current_element.is_a?(HTMLContent)
                    asian_char_regex = /([\p{Han}|\p{Katakana}|\p{Hiragana}|\p{Hangul}])(\s+)/
                    if current_element.str.match(asian_char_regex)
                        current_element.str.gsub!(asian_char_regex,'\1'+"[S]".yellow)
                        puts_warning("Ryukyu: No half-width spaces in Japanese characters", current_element.html_line, current_element.str)
                    end
                end

            end
        end


        #Display errors
        puts "Checked #{@file_path}"
        if @errors.length > 0 or @warnings.length > 0
            @errors.each do |error|
                puts "  #{error}"
            end

            @warnings.each do |warning|
                puts "  #{warning}"
            end
            puts
        else
            puts "  [Success][No errors found]"
            puts
        end
        puts

    end #initialize

    def get_tag_by_id(id)
        return @tags_by_id[id]
    end

    def get_tags_by_class(classname)
        return @tags_by_class[classname]
    end

    def print_elements(element,spaces)
        puts "#{spaces}#{element.str}"
        if element.is_a?(HTMLTagOpen)
            element.children.each do |child|
                print_elements(child, "  #{spaces}")
            end
            begin
                puts "#{spaces}#{element.closing_tag.str}"
            rescue
                puts "#{spaces}[Error]#{element.str} has no closing tag"
            end
        end
    end

    def to_s
        @file_path
    end

    #override this function for specific templating engines
    def process_line_through_templating_engine(str)
        #Default HTML file, do nothing
        return str
    end

    #Private and helper functions
    private
    def puts_error(error, line, details)
        @errors << "[Error]".red + " line #{line.line_number}: " + "[#{error}]".red
        @errors << "  #{details}\n\n"
    end

    def puts_warning(warning, line, details)
        @warnings << "[Warning]".yellow + " line #{line.line_number}: " + "[#{warning}]".yellow
        @warnings << "  #{details}\n\n"
    end

    #Recursive tree traversal check
    def check_all_elements(root_element)
        if root_element.is_a?(HTMLTagOpen) and !root_element.has_closing_tag
            puts_error("<#{root_element.type}> has no closing tag", root_element.html_line, root_element.html_line.str.strip)
        end

        #Recursion to traverse the full tree
        if root_element.is_a?(HTMLTagOpen)
            root_element.children.each do |child|
                check_all_elements(child) do |current_element|
                    yield(current_element)
                end
            end
        end

        #Insert custom checks on the element here        
        yield(root_element)
    end

end