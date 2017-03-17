require 'colorize'
require_relative 'CodeFile.rb'
require_relative 'HTMLLine.rb'

class HTMLFile < CodeFile
    #Root tags are used for searching the document
    attr_accessor :root_tags

    #Used for parsing the document
    attr_accessor :open_bracket_detected, 
                  :opening_tag_detected, 
                  :closing_tag_detected, 
                  :open_script_detected, 
                  :open_attribute_detected, 
                  :open_attribute_quote_detected,
                  :parent_tags_stash

    #Ryukyu check
    @@h1_tags = []

    def initialize(file_path)
        super(file_path)
    end #initialize

    def custom_set_codeline_class
        @codeline_class = HTMLLine
    end

    def custom_initialize_instance_variables
        @root_tags = []
        #Attributes used for parsing the document
        @open_bracket_detected = false
        @opening_tag_detected = false
        @closing_tag_detected = false
        @open_script_detected = false
        @open_attribute_detected = false
        @open_attribute_quote_detected = false
        @parent_tags_stash = []

        @tags_by_id = {}
        @tags_by_class = {}
    end
    
    def custom_check_file_after_processing_done
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
                    return if current_element.type == "path" #path is a foreign tag, allow "/" at the end

                    if current_element.str.match(/<\s*(\w+)\s*.*(\/\s*>)$/)
                        puts_warning("Ryukyu: void tag should not have '/' at end", current_element.code_line, current_element.code_line.str.strip)
                    end

                    if current_element.type == 'img'
                        if !current_element.str.match(/alt/)
                            puts_warning("Ryukyu: img tag needs alt attribute defined", current_element.code_line, current_element.code_line.str.strip)
                        end
                    end

                end

                #2) No half-width spaces in content
                if current_element.is_a?(HTMLContent)
                    asian_char_regex = /([\p{Han}|\p{Katakana}|\p{Hiragana}|\p{Hangul}])(\s+)/
                    if current_element.str.match(asian_char_regex)
                        current_element.str.gsub!(asian_char_regex,'\1'+" ".colorize(:background => :yellow))
                        puts_warning("Ryukyu: No half-width spaces in Japanese characters", current_element.code_line, current_element.str)
                    end
                end

                #3) Only one h1 tag
                if current_element.is_a?(HTMLTagOpen)
                    if current_element.type == 'h1'
                        @@h1_tags << current_element
                        if @@h1_tags.length > 1
                            warning_str = "This h1 tag: #{current_element.str}"
                            @@h1_tags.each  do |h1_tag|
                                 next if h1_tag == @@h1_tags.last
                                 warning_str = warning_str + "\n    Other h1 is tag in: #{h1_tag.code_line.code_file.file_path}: line #{h1_tag.code_line.line_number}"
                            end
                            puts_warning("Ryukyu: We usually use h1 for logo or page title.  Only one h1 per document.", current_element.code_line, warning_str)
                        end
                    end
                end
            end
        end
    end

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

    #override this function for specific templating engines
    def process_line_through_templating_engine(str)
        #Default HTML file, do nothing
        return str
    end

    #Private and helper functions
    private

    #Recursive tree traversal check
    def check_all_elements(root_element)
        if root_element.is_a?(HTMLTagOpen) and !root_element.has_closing_tag
            puts_error("<#{root_element.type}> has no closing tag", root_element.code_line, root_element.code_line.str.strip)
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