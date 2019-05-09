require "erb_to_jsx_quick_and_dirty/version"
require "active_support/core_ext/string/inflections"

module ErbToJsxQuickAndDirty
  class Runner
    SUBSTITUTIONS = {
      '<!--' => '{/*',
      '-->' => '*/}',
      '<%#' => '{/*',
      '#>' => '*/}',
      '<%=' => '{\'',
      '<%' => '{\'',
      '%>'  => '\'}',
      ' class=' => ' className=',
      ' for=' => ' htmlFor=',
    }

    def self.run(*args, &block)
      new.run(*args, &block)
    end

    # TODO: Support full directories
    def run(file_or_directory)
      if File.directory?(file_or_directory)
        Dir.glob("#{file_or_directory}/**/*.erb").each do |file|
          run_file(file)
        end
      else
        run_file(file_or_directory)
      end
    end

    def run_file(file_name)
      file_contents = File.read(file_name)
      SUBSTITUTIONS.each do |key, value|
        # require 'byebug'
        # debugger
        file_contents = file_contents.gsub(key, value)
      end

      # can't use extname here as it would change foo.html.erb => foo.html
      file_name_without_extension = File.basename(file_name).gsub(/^([^\.]+).*/) { $1 }

      component_name = file_name_without_extension.classify

      file_contents = <<-CODE
import React from 'react';

export class #{component_name} extends React.Component {
  constructor(props) {
    super(props)
  }

  render() {
    #{indent(file_contents, '    ')}
  }
}
CODE


      File.write("#{file_name_without_extension}.jsx", file_contents)
    end

  private

    def indent(str, indentation_mark)
      first_line = true

      str.split("\n").map do |line|
        if first_line
          first_line = false
          line
        else
          "#{indentation_mark}#{line}"
        end
      end.join("\n")
    end
  end
end
