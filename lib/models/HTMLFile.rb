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

    def initialize(file_path)
        super(file_path)

        if @root_tags.length == 0
            #Somewhere there was not a closing tag so the root was not 
            #discovered properly.  Manually add in the root
           @root_tags << @parent_tags_stash.first
        end
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

    #Recursive tree traversal check
    def check_all_elements(root_element)
        if root_element.is_a?(HTMLTagOpen) and !root_element.has_closing_tag
            self.errors << ValidationMessage.new(root_element.code_line.line_number, "<#{root_element.type}> has no closing tag", root_element.code_line.str.strip)
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