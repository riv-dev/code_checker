Gem::Specification.new do |s|
    s.name = 'code_checker'
    s.version = '1.0.1'
    s.date = '2017-03-02'
    s.summary = "Check HTML code and coding rules"
    s.authors = ["Ken Le"]
    s.email = "kenle545@gmail.com"
    s.files = ["lib/code_checker.rb",
                "lib/models/HTMLFile.rb",
                "lib/models/HTMLLine.rb",
                "lib/models/HTMLTag.rb",
                "lib/models/HTMLTagClose.rb",
                "lib/models/HTMLTagFactory.rb",
                "lib/models/HTMLTagOpen.rb",
                "lib/models/HTMLTagVoid.rb"]
    s.executables = ["code_checker"]
    s.homepage = 'https://github.com/riv-dev/welcome'
    s.license = 'MIT'
end