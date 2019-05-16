FROM node:8.16.0-alpine

RUN mkdir -p /var/lib/templates

WORKDIR /var/lib/templates

COPY run.sh /usr/local/bin/run.sh
COPY ruby_erb_parser.rb /usr/local/bin/ruby_erb_parser.rb

RUN chmod a+x /usr/local/bin/run.sh /usr/local/bin/ruby_erb_parser.rb

RUN touch /var/lib/templates/config_templates.csv

run apk add ruby ruby-json

ENTRYPOINT [ "/usr/local/bin/run.sh" ]

