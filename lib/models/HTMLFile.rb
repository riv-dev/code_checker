require 'nokogiri'
require_relative 'HTMLLine.rb'

class HTMLFile
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

            #At this point all HTML lines have been processed.
            #You may now iterate through the tags and look for errors or warnings
            #Insert all custom checks here
            check_all_tags do |current_line, current_tag|
                #Ryukyu coding rule, no <img /> style void tags
                if current_tag.is_a?(HTMLTagVoid)
                    if current_tag.str.match(/<\s*(\w+)\s*.*(\/\s*>)$/)
                        puts_warning("Ryukyu: void tag should not have '/' at end", current_line)
                    end
                end
            end

        end #File.open

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
    def puts_error(error, line)
        @errors << "[Error] line #{line.line_number}: [#{error}]"
        @errors << "  #{line.str.strip}\n\n"
    end

    def puts_warning(warning, line)
        @warnings << "[Warning] line #{line.line_number}: [#{warning}]"
        @warnings << "  #{line.str.strip}\n\n"
    end

    def check_all_tags
        @lines.each do |current_line|
            current_line.tags.each do |current_tag|
                #Default check.  Check all open tags have closing tags
                if current_tag.is_a?(HTMLTagOpen) and !current_tag.has_closing_tag
                    puts_error("<#{current_tag.type}> has no closing tag", current_line)
                end      

                #Custom checks get added here with the yield statement
                yield(current_line, current_tag)
            end
        end    
    end

end