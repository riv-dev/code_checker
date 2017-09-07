#encoding: utf-8
require_relative 'ValidationMessage.rb'

class RyukyuCrossValidator
    def initialize
        @html_files = nil
        @sass_files = nil
    end

    def validate(html_files,sass_files)
        @html_files = html_files
        @sass_files = sass_files

        #Cross checking
        #Collect all mixins and includes
        all_mixins = {}
        all_includes = []
        all_root_selectors = []

        #Collect all mixins, includes and selectors
        @sass_files.each do |sass_file|
            #Hash for speed performance
            sass_file.all_mixins.each do |mixin|
                all_mixins[mixin.name.strip] = mixin
            end

            all_includes.concat(sass_file.all_includes)
            all_root_selectors.concat(sass_file.root_selectors)
        end

        #Insert all defined mixins
        all_includes.each do |sass_include|
            if mixin = all_mixins[sass_include.name.strip]
                mixin.includes.each do |insert_include|
                    clone = insert_include.clone
                    clone.parent = sass_include.parent
                    sass_include.parent.includes << clone if sass_include.parent != nil
                end

                mixin.properties.each do |insert_property|
                    clone = insert_property.clone
                    clone.parent = sass_include.parent
                    sass_include.parent.properties << clone if sass_include.parent != nil
                end

                mixin.children_selectors.each do |insert_child_selector|
                    clone = deep_copy(insert_child_selector) #Do a deep copy
                    clone.parent = sass_include.parent
                    sass_include.parent.children_selectors << clone if sass_include.parent != nil
                end #insert
            end #if
        end #all_includes

        all_hover_selector_strings = []

        i = 0
        check_all_selectors(all_root_selectors) do |selector|
            if selector.name.match(/:hover/)
                #puts "#{i}. #{selector.name}"
                #i = i+1
                all_hover_selector_strings << selector.element_selector_string
            end      
        end

        #i=0
        #all_hover_selector_strings.each do |selector|
        #puts "#{i}. #{selector}"
        #i = i+1
        #end

        #Search through HTML files again to do cross-checking between SASS and HTML
        #puts "File #{file_name}"
        @html_files.keys.each do |file_name|
            page = Nokogiri::HTML(File.open(file_name))

            #Check hover styling
            all_tags_that_require_hover = page.css('a,input[type="submit"],input[type="reset"],input[type="button"],button')
            valid_tags_hover_applied = []

            all_hover_selector_strings.each do |selector_string|
                begin
                    #puts selector_string
                    tags_with_hover_applied = page.css(selector_string.gsub(/\.no-touchevents/,'')) #We understand no-touchevents
                    tags_with_hover_applied.each do |tag_with_hover_applied|
                        if tag_with_hover_applied.name.strip != "a" and tag_with_hover_applied.name.strip != "input" and tag_with_hover_applied.name.strip != "button"
                            line = @html_files[file_name].lines[result.line-1]
                            @html_files[file_name].warnings << ValidationMessage.new(line.line_number, "Ryukyu: Hover style should only be put on <a>, <input>, <button> tags", line.to_s.strip)
                        else
                            valid_tags_hover_applied << tag_with_hover_applied
                        end
                    end
                rescue => e
                    #puts e
                end #end begin
            end #end all_hover

            tags_that_need_hover = all_tags_that_require_hover.to_a - valid_tags_hover_applied

            tags_that_need_hover.each do |tag_that_needs_hover|
                line = @html_files[file_name].lines[tag_that_needs_hover.line-1]
                @html_files[file_name].warnings << ValidationMessage.new(line.line_number, "Ryukyu: No hover style is defined. <a>, <input>, <button> tags require hover", line.to_s.strip)
            end #end tags_that_need_hover

        end #end @html_files.keys.each
  end #end def

  private
  def deep_copy(selector)
    selector = selector.clone

    i = 0
    children_selectors = selector.children_selectors
    selector.children_selectors = []
    children_selectors.each do |child_selector|
      selector.children_selectors << child_selector.clone
      selector.children_selectors[i].parent = selector
      i = i+1
    end
    return selector
  end  

  def check_all_selectors(root_selectors)
    root_selectors.each do |root_selector|
      yield(root_selector)

      check_all_selectors(root_selector.children_selectors) do |sel|
        yield(sel)
      end
    end
  end

end