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
            if selector.name.match(/:hover/)
                current_parent = selector.parent
                while current_parent and !current_parent.is_a?(SASSMixin) and !current_parent.name.match(/@media/)
                    current_parent = current_parent.parent
                end

                if current_parent == nil
                    puts_warning("Ryukyu: Hover must be defined inside @media for PC only", selector.codeline, selector.codeline.str.chomp.strip)
                end
            elsif selector.name.match(/@media/)
                if selector.name.match(/max-width/)
                    puts_warning("Ryukyu: Use min-width only for @media", selector.codeline, selector.codeline.str.chomp.strip)
                end
            elsif selector.name.match(/^\s*[\w\-_]+/) or selector.name.match(/,\s*[\w\-_]+/)
                puts_warning("Ryukyu: Avoid styling directly on HTML tag, define a class instead.", selector.codeline, selector.codeline.str.chomp.strip)
            end
        end

        check_all_includes do |sass_include|
            if sass_include.name.match(/transition/)
                if sass_include.parent.name.match(/hover/)
                   puts_warning("Ryukyu: transition should not be put inside hover", sass_include.codeline, sass_include.codeline.str.chomp.strip)
                end
            end

            if sass_include.name.match(/flex/)
                puts_warning("Ryukyu: Don't use flexbox because old version of IE and Android does not support.", sass_include.codeline, sass_include.codeline.str.chomp.strip)
            end
        end

        check_all_properties do |sass_property|
            if sass_property.name.match(/line-height/)
                unless sass_property.value.match(/em/) or sass_property.value.match(/\d$/)
                    puts_warning("Ryukyu: Use em or unitless for line-height, because em can change dynamically with the font in use.", sass_property.codeline, sass_property.codeline.str.chomp.strip)
                end
            elsif sass_property.name.match(/font-size/)
                if !sass_property.value.match(/px/)
                    puts_warning("Ryukyu: Use px for font-size,don't use em, rem, %... , because it offers absolute control over text.", sass_property.codeline, sass_property.codeline.str.chomp.strip)
                end
            elsif sass_property.name.match(/display/)
                if sass_property.value.match(/flex/)
                    puts_warning("Ryukyu: Don't use flexbox because old version of IE and Android does not support.", sass_property.codeline, sass_property.codeline.str.chomp.strip)
                end
            end

            if sass_property.value.match(/calc/)
                puts_warning("Ryukyu: Don't use calc because old version of IE and Android does not support.", sass_property.codeline, sass_property.codeline.str.chomp.strip)
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