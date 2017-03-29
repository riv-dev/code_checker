require_relative 'CodeFile.rb'
require_relative 'SASSLine.rb'
require_relative 'SASSMixin.rb'

class SASSFile < CodeFile

    #Used for parsing the document
    attr_accessor :open_selector_bracket_detected,
                  :open_function_detected,
                  :open_include_detected,
                  :parents_stash,
                  :root_selectors,
                  :all_selectors,
                  :all_mixins,
                  :all_includes,
                  :all_properties


    def initialize(file_path)
        super(file_path)

        #print_all
    end #initialize

    #Override this method in the child class
    def custom_set_codeline_class
        @codeline_class = SASSLine
    end

    #Override this method in the child class
    def custom_initialize_instance_variables
        @open_selector_bracket_detected = false
        @open_function_detected = false
        @open_include_detected = false
        @parents_stash = []
        @root_selectors = []
        @all_selectors = []
        @all_mixins = []
        @all_includes = []
        @all_properties = []
     end
    
    def check_all_properties
        @all_properties.each do |property|
            yield(property)
        end
    end

    def check_all_selectors
        @all_selectors.each do |selector|
            yield(selector)
        end
    end

    def check_all_includes
        @all_includes.each do |sass_include|
            yield(sass_include)
        end
    end

    def print_all
        @root_selectors.each do |root_selector|
            print_all_selector(root_selector,"")
        end
    end

    def print_all_selector(root_selector,spaces)
        puts "#{spaces}#{root_selector} {"    

        root_selector.includes.each do |sass_include|
            #puts "Selector string: #{sass_include.element_selector_string}"
            puts "#{spaces}  #{sass_include}"
        end

        root_selector.properties.each do |property|
            #puts "Selector string: #{property.element_selector_string}"
            puts "#{spaces}  #{property}"
        end

        root_selector.children_selectors.each do |child|
            print_all_selector(child, "#{spaces}  ")
        end

        puts "#{spaces}}"
    end
end