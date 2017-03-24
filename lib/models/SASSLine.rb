require_relative 'CodeLine.rb'
require_relative 'SASSSelector.rb'
require_relative 'SASSProperty.rb'
require_relative 'SASSInclude.rb'
require_relative 'SASSDirective.rb'
require_relative 'SASSKeyFrames.rb'

class SASSLine < CodeLine
    attr_accessor :selectors

    @@current_undefined_str = ""
    @@include_open_bracket_stash = []        
    @@function_open_bracket_stash = []

    def initialize(code_file, line_str, line_number)
        super(code_file, line_str, line_number)
    end    

    #Override method
    def custom_initialize_instance_variables

    end

    #Override method
    def custom_process_line(str)
        if @line_number == 1
            if !str.match(/^\s*@charset\s+"utf-8"/)
                puts_warning('First line should contain @charset "utf-8";', @line_number)
            else
                #We are good, ignore the line
                return
            end
        end

        #remove comments <!-- -->
        str.gsub!(/\/\/.*/,'')

        if @code_file.open_comment_detected and str.gsub!(/.*?\*\//, ' ')
            #puts "end of comment"
            #puts "  #{str}"
            @code_file.open_comment_detected = false
        elsif @code_file.open_comment_detected
            #puts "comment ignored"
            #puts "  #{str}"
            #don't process the line
            return
        elsif str.gsub!(/\/\*.*?\*\//, ' ')
            #puts "comment removed"
            #puts " #{str}"
            @code_file.open_comment_detected = false
        elsif str.gsub!(/\/\*.*/, ' ')
            #puts "open comment detected line:#{@line_number}}"
            #puts "  #{str}"
            @code_file.open_comment_detected = true
        end

        #Ignore imports
        if str.match(/^\s*@import/)
            return
        end

        #Ignore variables
        if str.match(/^\s*\$\w+/)
            return
        end

        #Process includes and includes that have open and closing brackets { }
        if @code_file.open_include_detected and captures = str.scan(/\{/)
            captures.length.times do
                @@include_open_bracket_stash << "{"
            end
            return
        elsif @code_file.open_include_detected and captures = str.scan(/\}/)
            captures.length.times do 
                @@include_open_bracket_stash.pop
            end

            if @@include_open_bracket_stash.length == 0
                @code_file.open_include_detected = false
            end

            return
        elsif @code_file.open_include_detected
            #puts "comment ignored"
            #puts "  #{str}"
            #don't process the line
            return
        elsif captures = str.match(/^\s*@include\s*([\w\-_]+)\(?([$\w\-_,\s+]*)\)?/)
            name = captures[1]
            parameters = nil
            parameters = captures[2] if captures.length == 3
            current_include = SASSInclude.new(self, @code_file.parents_stash.last, name, parameters)
            @code_file.parents_stash.last.includes << current_include if @code_file.parents_stash.last != nil
            @code_file.all_includes << current_include

            if captures = str.scan(/\{/)
                @code_file.open_include_detected = true if captures.length > 0
                captures.length.times do
                    @@include_open_bracket_stash << "{"
                end
            end
            #puts "open comment detected line:#{@line_number}}"
            #puts "  #{str}"
            return
        end       


        #Remove functions
        if @code_file.open_function_detected and captures = str.scan(/\{/)
            captures.length.times do
                @@function_open_bracket_stash << "{"
            end
            return
        elsif @code_file.open_function_detected and captures = str.scan(/\}/)
            captures.length.times do 
                @@function_open_bracket_stash.pop
            end

            if @@function_open_bracket_stash.length == 0
                @code_file.open_function_detected = false
            end

            return
        elsif @code_file.open_function_detected
            #puts "comment ignored"
            #puts "  #{str}"
            #don't process the line
            return
        elsif str.match(/^\s*@function/)
            if captures = str.scan(/\{/)
                captures.length.times do
                    @@function_open_bracket_stash << "{"
                end
            end
            #puts "open comment detected line:#{@line_number}}"
            #puts "  #{str}"
            @code_file.open_function_detected = true
            return
        end

        #Remove #{$n} style variable insertions
        str.gsub!(/#\{(\s*.*?\s*)\}/,'\1'.strip)

        #Check for ending ";"        
        if str.match(/[\w\)]\s*$/)
           puts_error('Missing ; at end of the line', @line_number) 
           puts_error_location(str,str.length)
           #Correct the string so we can properly continue the check below
           str = str + ";"
        end

        #Add ";" to end of line with style .style {property:value}
        str.gsub!(/(\w+)\s*\}\s*$/,'\1;}')

        i = 1
        str.split("").each do |char|
            #.foo {
            #   color: white;
            #   background-color: black;
            #}

            #.foo {
            #   .bar {
            #       color:white;
            #    }
            #}

            #.foo {
            #   color: white;
            #   .bar {
            #       color:black;
            #   }
            #   font-size: 14px;
            #}

            if char == "{"
                #@@current_undefined_str is a selector
                if captures = @@current_undefined_str.match(/^\s*(@mixin\s+)([A-Za-z\-\_]+)\s*(\((.*)\))?\s*$/)
                #Detect mixins
                    current_parent = @code_file.parents_stash.last
                    if current_parent != nil
                        puts_error('Mixin cannot be nested inside parent selector', @line_number) 
                        puts_error_location(str,str.length)
                    end
                    current_selector = SASSMixin.new(self, captures[2], captures[4])
                    @code_file.all_mixins << current_selector
                elsif captures = @@current_undefined_str.match(/(^\s*@if|^\s*@for|^\s*@while|^\s*@each|^\s*@else)/)
                    current_selector = SASSDirective.new(self, captures[1].chomp.strip)
                elsif captures = @@current_undefined_str.match(/^\s*@keyframes\s+(.*)/)
                    current_selector = SASSKeyFrames.new(self, captures[1].chomp.strip)
                else
                    #Find the current parent, ignore sass directives
                    current_parent = nil
                    @code_file.parents_stash.reverse.each do |parent|
                        if parent and !parent.is_a?(SASSDirective)
                            current_parent = parent
                            break
                        end
                    end

                    current_selector = SASSSelector.new(self, @@current_undefined_str.chomp.strip, current_parent)
                    current_parent.children_selectors << current_selector if current_parent != nil
                    @code_file.all_selectors << current_selector
                end

                @code_file.parents_stash << current_selector
                #Reset str
                @@current_undefined_str = ""
            elsif char == "}"
                selector = @code_file.parents_stash.pop

                if !selector.is_a?(SASSDirective)
                    if @code_file.parents_stash.length == 0 and selector != nil
                        @code_file.root_selectors << selector
                    else
                        all_directives = true

                        @code_file.parents_stash.each do |parent|
                            all_directives = false if !parent.is_a?(SASSDirective)
                            break
                        end

                        @code_file.root_selectors << selector if all_directives and selector != nil
                    end
                end
            elsif char == ";"
                #@@current_undefined_str is a property value
                values = @@current_undefined_str.chomp.strip.split(":")

                if values.length == 2
                    #Find the current parent, ignore sass directives
                    current_parent = nil
                    @code_file.parents_stash.reverse.each do |parent|
                        if parent and !parent.is_a?(SASSDirective)
                            current_parent = parent
                            break
                        end
                    end

                    current_css_property = SASSProperty.new(self, current_parent, values[0].strip.chomp, values[1].strip.chomp)
                    @code_file.parents_stash.last.properties << current_css_property if @code_file.parents_stash.last != nil
                    @code_file.all_properties << current_css_property
                elsif values.length == 1
                    #it is not a valid CSS property:value pair
                    #possibly it is a sass mixin or extend
                else #syntax error
                    #puts error
                    puts_error("Invalid line.", @line_number)
                    puts_error_location(@@current_undefined_str, i)
                end

                #Reset str
                @@current_undefined_str = ""
            else
                if char != "\r" and char != "\n"
                    @@current_undefined_str << char
                end               
            end #end if

            i = i + 1
        end #end do 

    end # end def
end