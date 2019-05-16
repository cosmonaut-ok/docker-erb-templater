#!/usr/bin/env ruby

# usage:
# ruby json_erb_render.rb OPTIONS

# help:
# ruby json_erb_render.rb --help

# examples:
# ruby json_erb_render.rb -i ./example/foo.erb -d ./example/config.json
# ruby json_erb_render.rb -i ./example/foo.erb -d ./example/config.json -o ./out.txt
# ruby json_erb_render.rb -t "FOO_BAR=<%= @config['foo']['bar'] %>" -d ./example/config.json
# ruby json_erb_render.rb -t "FOO_BAR=<%= @config['foo']['bar'] %>" -p "{\"foo\":\"bar\"}"
# ruby json_erb_render.rb -t "FOO_BAR=<%= @config['foo']['bar'] %>" -p "{\"foo\":\"bar\"}" -o ./out.txt

require 'erb'
require 'json'
require 'pathname'
require 'optparse'
require 'ostruct'
require 'fileutils'

# options = OpenStruct.new
# OptionParser.new do |opt|
#   opt.on('-i', '--input_file TEMPLATE_FILE', 'The template file being processed. e.g.: ./example/foo.erb') { |o| options['input_file'] = o }
#   opt.on('-t', '--template_text TEMPLATE_TEXT', 'The template text being processed. e.g.: "FOO_BAR=<%= @config[\'foo\'][\'bar\'] %>"') { |o| options['template_text'] = o }
#   opt.on('-d', '--data_file DATA_FILE', 'The config file (json) being processed. e.g.: ./example/config.json') { |o| options['data_file'] = o }
#   opt.on('-p', '--template_params TEMPLATE_PARAMS', 'The template params (json) being processed. e.g.: -p "{\"foo\":\"bar\"}"') { |o| options['template_params'] = o }
#   opt.on('-o', '--output_file SINK_FILE', 'The output file. if not specified, output gets rendered to stdout. e.g.: ./out.txt') { |o| options['output_file'] = o }
# end.parse!

## tp = ENV['TEMPLATE_PARAMS']

home="/var/lib/templates"

template_file_map = {}

IO.readlines(File.join(home, 'config_templates.csv')).each do |line|
  kv = line.gsub("\n", "").split(":")
  template_file_map[kv[0]] = kv[1]
end

config_data = JSON.parse(ENV['TEMPLATE_PARAMS'])

# template_file = options['input_file']
# output_file = options['output_file']

class TemplateBuilder
  attr_accessor :config

  def initialize(config)
    @config = config
  end

  # Expose private binding() method.
  def get_binding
    binding()
  end

end

template_file_map.each_pair do |key, value|
  dirname = Pathname(value).dirname
  FileUtils.mkdir_p(dirname)

  output = File.new(value, 'w')
  template = File.read(File.join(home, key))
  
  renderer = ERB.new(template)
  builder = TemplateBuilder.new(config_data)
  result = renderer.result(builder.get_binding)
  
  output.puts(result)
  output.close
end

