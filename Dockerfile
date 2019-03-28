FROM docker.elastic.co/logstash/logstash:6.5.4

USER root

RUN yum install -y sudo git vim
RUN logstash-plugin install logstash-filter-prune

USER logstash
ENV PATH=$PATH:/usr/share/logstash/vendor/jruby/bin/
RUN gem install bundler

ADD config /usr/share/logstash/config
ADD pipeline /usr/share/logstash/pipeline
RUN chown -r logstash /usr/share/logstash/config /usr/share/logstash/pipeline
RUN git clone https://github.com/liatrio/logstash-input-jira.git /usr/share/logstash/plugins/logstash-input-jira

WORKDIR /usr/share/logstash/plugins/logstash-input-jira
RUN bundler install 
RUN gem build /usr/share/logstash/plugins/logstash-input-jira/logstash-input-jira.gemspec

WORKDIR /usr/share/logstash
RUN logstash-plugin install /usr/share/logstash/plugins/logstash-input-jira/logstash-input-jira-*.gem
