#!/bin/sh

HOME=/var/lib/templates

if ! test -f ${HOME}/config_templates.csv; then
    echo "Fuck you"
    exit 1
else
    CONFIG_TEMPLATES=$(cat ${HOME}/config_templates.csv)
fi

for i in $CONFIG_TEMPLATES; do
    tmpl_="$(echo $i | cut -d':' -f1)"
    file_="$(echo $i | cut -d':' -f2)"

    ruby `dirname $0`/ruby_erb_super_parser.rb -i ${HOME}/$tmpl_ -o $file_ -p $TEMPLATE_PARAMS
done

# Usage: ruby_erb_parser [options]
#     -i, --input_file TEMPLATE_FILE   The template file being processed. e.g.: ./example/foo.erb
#     -t TEMPLATE_TEXT,                The template text being processed. e.g.: "FOO_BAR=<%= @config['foo']['bar'] %>"
#         --template_text
#     -d, --data_file DATA_FILE        The config file (json) being processed. e.g.: ./example/config.json
#     -p TEMPLATE_PARAMS,              The template params (json) being processed. e.g.: -p "{\"foo\":\"bar\"}"
#         --template_params
#     -o, --output_file SINK_FILE      The output file. if not specified, output gets rendered to stdout. e.g.: ./out.txt
