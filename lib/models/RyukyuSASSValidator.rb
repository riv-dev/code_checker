#encoding: utf-8
require_relative 'ValidationMessage.rb'

class RyukyuSASSValidator
    def initialize

    end

    def validate(sass_file)
        sass_file.check_all_properties do |property|
            line_number = property.codeline.line_number
            line_str = property.codeline.str.chomp.strip
            SASSInclude.get_common_include_names.each do |include_name|
                if property.name.match(/#{include_name}/)
                    sass_file.warnings << ValidationMessage.new(line_number, "Ryukyu: Use compass mixin @include #{include_name}()", line_str)                    
                end
            end
        end

        sass_file.check_all_selectors do |selector|
            line_number = selector.codeline.line_number
            line_str = selector.codeline.str.chomp.strip

            if selector.name.match(/:hover/)
                if selector.element_selector_string.match(/^\s*\.no-touchevents/)
                    #We are good
                    next
                else
                    #Needs to be wrapped inside @media for PC
                    current_parent = selector.parent
                    while current_parent and !current_parent.is_a?(SASSMixin) and !current_parent.name.match(/@media/)
                        current_parent = current_parent.parent
                    end

                    if current_parent == nil
                        sass_file.warnings << ValidationMessage.new(line_number, "Ryukyu: Hover must be defined inside @media for PC only or using .no-touchevents class", line_str)
                    end
                end

            elsif selector.name.match(/@media/)
                if selector.name.match(/max-width/)
                    sass_file.warnings << ValidationMessage.new(line_number, "Ryukyu: Use min-width only for @media", line_str)
                end
            elsif selector.is_a?(SASSSelector) and (selector.name.match(/^\s*[a-z\-_]+/) or selector.name.match(/,\s*[a-z\-_]+/))
                sass_file.warnings << ValidationMessage.new(line_number, "Ryukyu: Avoid styling directly on HTML tag, define a class instead.", line_str)
            end
        end

        sass_file.check_all_includes do |sass_include|
            line_number = sass_include.codeline.line_number
            line_str = sass_include.codeline.str.chomp.strip

            if sass_include.name.match(/transition/)
                if sass_include.parent.name.match(/hover/)
                   sass_file.warnings << ValidationMessage.new(line_number, "Ryukyu: transition should not be put inside hover", line_str)
                end
            end

            if sass_include.name.match(/flex/)
                sass_file.warnings << ValidationMessage.new(line_number, "Ryukyu: Don't use flexbox because old version of IE and Android does not support.", line_str)
            end
        end

        sass_file.check_all_properties do |sass_property|
            line_number = sass_property.codeline.line_number
            line_str = sass_property.codeline.str.chomp.strip

            if sass_property.name.match(/line-height/)
                unless sass_property.value.match(/em/) or sass_property.value.match(/\d$/)
                    if(!sass_property.parent.name.match(/button|btn/))
                        sass_file.warnings << ValidationMessage.new(line_number, "Ryukyu: Use em or unitless for line-height, because em can change dynamically with the font in use.", line_str)
                    end
                end
            elsif sass_property.name.match(/font-size/)
                if !sass_property.value.match(/px/)
                    sass_file.warnings << ValidationMessage.new(line_number, "Ryukyu: Use px for font-size,don't use em, rem, %... , because it offers absolute control over text.", line_str)
                end
            elsif sass_property.name.match(/display/)
                if sass_property.value.match(/flex/)
                    sass_file.warnings << ValidationMessage.new(line_number, "Ryukyu: Don't use flexbox because old version of IE and Android does not support.", line_str)
                end
            end

            if sass_property.value.match(/calc/)
                sass_file.warnings << ValidationMessage.new(line_number, "Ryukyu: Don't use calc because old version of IE and Android does not support.", line_str)
            end
        end

    end

end