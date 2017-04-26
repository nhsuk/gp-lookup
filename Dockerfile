FROM ubuntu:14.04

WORKDIR /app

COPY Gemfile* /app/

RUN apt-get update
RUN apt-get install -y build-essential make curl
RUN apt-get install locales
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
RUN \curl -L https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm install ruby-2.2.3"
RUN /bin/bash -l -c "rvm use --default ruby-2.2.3"
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"
RUN apt-get install -y nodejs
RUN /bin/bash -l -c "bundle install"
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

COPY . /app/

EXPOSE 9292:9292
EXPOSE 3000:3000
CMD /bin/bash -l -c "bundle exec rackup"