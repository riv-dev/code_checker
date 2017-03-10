require_relative 'CodeFile.rb'
require_relative 'SASSLine.rb'

class SASSFile < CodeFile

    #Used for parsing the document
    attr_accessor :open_selector_bracket_detected,
                  :parent_selectors_stash,
                  :root_selectors

    def initialize(file_path)
        super(file_path)
    end #initialize

    #Override this method in the child class
    def custom_set_codeline_class
        @codeline_class = SASSLine
    end

    #Override this method in the child class
    def custom_initialize_instance_variables
        @open_selector_bracket_detected = false
        @parent_selectors_stash = []
        @root_selectors = []
     end
    
    #Override this method in the child class
    def custom_check_file_after_processing_done

    end

    def print_all
        @root_selectors.each do |root_selector|
            print_all_selector(root_selector,"")
        end
    end

    def print_all_selector(root_selector,spaces)
        puts "#{spaces}#{root_selector} {"
        root_selector.properties.each do |property|
            puts "#{spaces}  #{property}"
        end

        root_selector.children_selectors.each do |child|
            print_all_selector(child, "#{spaces}  ")
        end

        puts "#{spaces}}"
    end
end