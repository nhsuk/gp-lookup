FROM ubuntu:14.04

WORKDIR /app


ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV ALLOWED_ORIGINS "https://localhost:3334"

RUN apt-get update && \
    apt-get install -y build-essential make curl locales nodejs && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales
RUN curl -L https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm install ruby-2.2.3"
RUN /bin/bash -l -c "rvm use --default ruby-2.2.3"
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"

COPY Gemfile* /app/
RUN /bin/bash -l -c "bundle install"

ADD . /app/

EXPOSE 9292:9292
EXPOSE 9393:9393
CMD /bin/bash -l -c "bundle exec rackup -o 0.0.0.0 -p 9292"
