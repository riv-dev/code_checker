require_relative 'CodeFile.rb'
require_relative 'SASSLine.rb'
require_relative 'SASSMixin.rb'

class SASSFile < CodeFile

    #Used for parsing the document
    attr_accessor :open_selector_bracket_detected,
                  :open_function_detected,
                  :parent_selectors_stash,
                  :root_selectors,
                  :all_properties,
                  :all_selectors,
                  :all_includes

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
        @parent_selectors_stash = []
        @root_selectors = []
        @all_properties = []
        @all_selectors = []
        @all_includes = []
     end
    
    #Override this method in the child class
    def custom_check_file_after_processing_done
        check_all_properties do |property|
            SASSInclude.get_common_include_names.each do |include_name|
                if property.name.match(/#{include_name}/)
                    puts_warning("Ryukyu: Use compass mixin @include #{include_name}()", property.codeline, property.codeline.str.chomp.strip)                    
                end
            end
        end

        check_all_selectors do |selector|
            if selector.name.match(/hover/)
                unless selector.parent_selector and selector.parent_selector.name.match(/@media/)
                    puts_warning("Ryukyu: Hover must be defined inside @media for PC only", selector.codeline, selector.codeline.str.chomp.strip)
                end
            end
        end

        check_all_includes do |sass_include|
            if sass_include.name.match(/transition/)
                if sass_include.selector.name.match(/hover/)
                   puts_warning("Ryukyu: transition should not be put inside hover", sass_include.codeline, sass_include.codeline.str.chomp.strip)
                end
            end
        end
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
        if root_selector.is_a?(SASSMixin)
            puts "#{spaces}@mixin #{root_selector} {"
        else
            puts "#{spaces}#{root_selector} {"    
        end

        root_selector.includes.each do |sass_include|
            puts "#{spaces}  #{sass_include}"
        end

        root_selector.properties.each do |property|
            puts "#{spaces}  #{property}"
        end

        root_selector.children_selectors.each do |child|
            print_all_selector(child, "#{spaces}  ")
        end

        puts "#{spaces}}"
    end
end