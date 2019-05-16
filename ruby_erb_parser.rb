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

options = OpenStruct.new
OptionParser.new do |opt|
  opt.on('-i', '--input_file TEMPLATE_FILE', 'The template file being processed. e.g.: ./example/foo.erb') { |o| options['input_file'] = o }
  opt.on('-t', '--template_text TEMPLATE_TEXT', 'The template text being processed. e.g.: "FOO_BAR=<%= @config[\'foo\'][\'bar\'] %>"') { |o| options['template_text'] = o }
  opt.on('-d', '--data_file DATA_FILE', 'The config file (json) being processed. e.g.: ./example/config.json') { |o| options['data_file'] = o }
  opt.on('-p', '--template_params TEMPLATE_PARAMS', 'The template params (json) being processed. e.g.: -p "{\"foo\":\"bar\"}"') { |o| options['template_params'] = o }
  opt.on('-o', '--output_file SINK_FILE', 'The output file. if not specified, output gets rendered to stdout. e.g.: ./out.txt') { |o| options['output_file'] = o }
end.parse!



data_file = options['data_file']
data_text = options['template_params']

template_file = options['input_file']
template_text = options['template_text']

output_file = options['output_file']

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

if template_file ==nil
  template=template_text
else
  template=File.read(template_file)
end

if data_file ==nil
  params=JSON.parse(data_text)
else
  params=JSON.parse(File.read(data_file))
end


renderer = ERB.new(template)
builder = TemplateBuilder.new(params)
result = renderer.result(builder.get_binding)

if output_file==nil
  puts result
else
  output = File.new(output_file, 'w')
  output.puts(result)
  output.close
end


