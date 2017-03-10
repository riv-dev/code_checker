require_relative 'CodeLine.rb'
require_relative 'SASSSelector.rb'
require_relative 'SASSProperty.rb'

class SASSLine < CodeLine
    attr_accessor :selectors

    @@current_undefined_str = ""
    @@mixin_detected = false;

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

        #Check for ending ";"        
        if str.match(/\w+\s*$/)
           puts_error('Missing ; at end of the line', @line_number) 
           puts_error_location(str,str.length)
           #Correct the string so we can properly continue the check below
           str = str + ";"
        end

        #Ignore imports
        if str.match(/^s*@import/)
            return
        end

        #Ignore variables
        if str.match(/^s*\$\w+/)
            return
        end

        #Detect mixins
        if str.gsub!(/^s*(@mixin\s+)([A-Za-z\-_]+.*)/,'\2')
            @@mixin_detected = true
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

        #Remove functions
        if @code_file.open_function_detected and str.match(/.*}$/)
            #puts "end of comment"
            #puts "  #{str}"
            @code_file.open_function_detected = false
            return
        elsif @code_file.open_function_detected
            #puts "comment ignored"
            #puts "  #{str}"
            #don't process the line
            return
        elsif str.match(/^\s*@function/)
            #puts "open comment detected line:#{@line_number}}"
            #puts "  #{str}"
            @code_file.open_function_detected = true
            return
        end

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
                if @@mixin_detected
                    current_parent_selector = @code_file.parent_selectors_stash.last
                    if current_parent_selector != nil
                        puts_error('Mixin cannot be nested inside parent selector', @line_number) 
                        puts_error_location(str,str.length)
                    end
                    current_selector = SASSMixin.new(self, @@current_undefined_str.strip.chomp)
                    @@mixin_detected = false
                else
                    current_parent_selector = @code_file.parent_selectors_stash.last
                    current_selector = SASSSelector.new(self, @@current_undefined_str.strip.chomp, current_parent_selector)
                    current_parent_selector.children_selectors << current_selector if current_parent_selector != nil
                end

                @code_file.parent_selectors_stash << current_selector
                #Reset str
                @@current_undefined_str = ""
            elsif char == "}"
                selector = @code_file.parent_selectors_stash.pop
                @code_file.root_selectors << selector if @code_file.parent_selectors_stash.length == 0 and selector != nil
            elsif char == ";"
                #@@current_undefined_str is a property value
                values = @@current_undefined_str.split(":")

                if values.length == 2
                    current_css_property = SASSProperty.new(self, @code_file.parent_selectors_stash.last, values[0].strip.chomp, values[1].strip.chomp)
                    @code_file.parent_selectors_stash.last.properties << current_css_property
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
                @@current_undefined_str << char;
            end #end if

            i = i + 1
        end #end do 

    end # end def
end