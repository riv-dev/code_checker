require 'nokogiri'
require_relative 'models/HTMLFile.rb'
require_relative 'models/HTMLFileFactory.rb'
require_relative 'models/SASSFile.rb'
require_relative 'views/ErrorView.rb'

class CodeChecker

  @@all_html_files = {} #Hash for easy searching
  @@all_sass_files = []

  def self.hi
    puts "Hello World!"
  end

  #Run code checker on a specific file
  def self.check(file_path, options)
    sass_file = nil
    html_file = nil
    begin
      captures = file_path.match(/\.(\w+)$/).captures
      if(captures[0] == 'scss')
        sass_file = SASSFile.new(file_path)
      else
        html_file = HTMLFileFactory.create(html_file, captures[0])
      end
    rescue
      html_file = HTMLFile.new(file_path)
    end

    ErrorView.new(html_file, options[:output_file]) if html_file
    ErrorView.new(sass_file, options[:output_file]) if sass_file
  end

  #Run code checker on files within the folder
  def self.check_folder(folders, options)
    puts "Code Checker running, please wait..."
    #Process options
    #By default check all types
    types = HTMLFileFactory.get_supported_types
    #if types option is defined, check only the specified types
    types = options[:types] if options[:types] != nil and options[:types].length > 0

    #import file and folder exclusion options
    @@exclude_files = options[:exclude_files]
    @@exclude_folders = options[:exclude_folders]

    #Clear the output file
    if options[:output_file]
      f = open(options[:output_file],'w')
      f.close
    end

    #Run the checker for files and folders that have not been excluded
    types.each do |file_type|
      #puts "Checking #{file_type} files"
      #puts
      folders.each do |folder|
        Dir.glob(folder+"/**/*.#{file_type}") do |file_name|
          @@all_html_files[file_name] = HTMLFileFactory.create(file_name, file_type) if !self.ignore_file?(file_name)
        end 
      end
    end #type.each do

    #Check SASS Files
    folders.each do |folder|
      Dir.glob(folder+"/**/*.scss") do |file_name|
        @@all_sass_files << SASSFile.new(file_name) if !self.ignore_file?(file_name)
      end     
    end

    #Cross checking
    #Collect all mixins and includes
    all_mixins = {}
    all_includes = []
    all_root_selectors = []
    @@all_sass_files.each do |sass_file|
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
            clone = self.deep_copy(insert_child_selector) #Do a deep copy
            clone.parent = sass_include.parent
            sass_include.parent.children_selectors << clone if sass_include.parent != nil
          end #insert
      end #if
    end #all_includes

    all_hover_selector_strings = []

    self.check_all_selectors(all_root_selectors) do |selector|
      if selector.name.match(/:hover/)
        all_hover_selector_strings << selector.element_selector_string
      end      
    end
  
    #all_hover_selector_strings.each do |selector|
    #  puts "1. #{selector}"
    #end

    #Search through HTML files again to do cross-checking between SASS and HTML
    types.each do |file_type|
      #puts "Cross-checking #{file_type} files"
      #puts
      folders.each do |folder|
        Dir.glob(folder+"/**/*.#{file_type}") do |file_name|
          #puts "File #{file_name}"
          page = Nokogiri::HTML(File.open(file_name))

          #Check hover styling
          results_all_tags_that_require_hover = page.css('a,input[type="submit"],input[type="reset"],input[type="button"],button')
          results_hover_applied = []

          all_hover_selector_strings.each do |selector_string|
            begin
              results = page.css(selector_string)
              results.each do |result|
                if result.name.strip != "a" and result.name.strip != "input" and result.name.strip != "button"
                  line = @@all_html_files[file_name].lines[result.line-1]
                  @@all_html_files[file_name].puts_warning("Ryukyu: Hover style should only be put on <a>, <input>, <button> tags", line, line.to_s.strip)
                else
                  results_hover_applied << result
                end
              end
            rescue => e
              #Parse error
            end #end begin
          end #end all_hover

          tags_that_need_hover = results_all_tags_that_require_hover.to_a - results_hover_applied

          tags_that_need_hover.each do |tag_that_needs_hover|
            line = @@all_html_files[file_name].lines[tag_that_needs_hover.line-1]
            @@all_html_files[file_name].puts_warning("Ryukyu: No hover style is defined. <a>, <input>, <button> tags require hover", line, line.to_s.strip)
          end
        end #end Dir.glob
      end #folders.each
    end #type.each do


    #Done with all checks, display all the errors
    @@all_html_files.keys.each do |file_name|
      ErrorView.new(@@all_html_files[file_name], options[:output_file])
    end

    @@all_sass_files.each do |file|
      ErrorView.new(file, options[:output_file])
    end

  end #def self.check_folder

  def self.deep_copy(selector)
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

  def self.check_all_selectors(root_selectors)
    root_selectors.each do |root_selector|
      yield(root_selector)

      self.check_all_selectors(root_selector.children_selectors) do |sel|
        yield(sel)
      end
    end
  end

  private
  #Helper functions
  #Returns true if options have been set to ignore the file
  def self.ignore_file?(path)
    path_components = path.split("/");
    filename = path_components.last

    if @@exclude_files != nil
      @@exclude_files.each do |exclude_file|
        #Check for wildcards in exclude_file name
        if exclude_file.match(/\*.+\*/) #match front and back
          term = exclude_file.gsub(/\*/,'')
          return true if filename.match(/#{term}/)
        elsif exclude_file.match(/\*.*\w$/) #match back only
          term = exclude_file.gsub(/\*/,'')
          return true if filename.match(/#{term}$/)
        elsif exclude_file.match(/.+\*$/) #match front only
          term = exclude_file.gsub(/\*/,'')
          return true if filename.match(/^#{term}/)
        else #no wildcard, match exactly
          return true if filename == exclude_file
        end
      end  
    end

    path_components.pop #pop off the filename, leave the folder path only

    if @@exclude_folders != nil
      @@exclude_folders.each do |exclude_folder|
        #Check for wildcards in exclude_folder name
        if exclude_folder.match(/\*.+\*/) #match front and back
            term = exclude_folder.gsub(/\*/,'')
            path_components.each do |folder_name|
              return true if folder_name.match(/#{term}/)
            end
          elsif exclude_folder.match(/\*.*\w$/) #match back only
            term = exclude_folder.gsub(/\*/,'')
            path_components.each do |folder_name|
              return true if folder_name.match(/#{term}$/)
            end
          elsif exclude_folder.match(/.+\*$/) #match front only
            term = exclude_folder.gsub(/\*/,'')
            path_components.each do |folder_name|
              return true if folder_name.match(/^#{term}/)
            end            
          else #no wildcard, match exactly
            path_components.each do |folder_name|
              return true if folder_name == exclude_folder
            end            
          end
      end
    end

    return false
  end

end