FROM ruby:3.0.0

ENV LANG C.UTF-8

COPY Gemfile* ./

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
      build-essential \
      mysql-client \
      curl -sL https://deb.nodesource.com/setup_10.x | bash - && apt-get install -y \
        nodejs \
        yarn \
        unzip && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* && \
      ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

ENV APP_HOME rails_docker

RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY Gemfile /${APP_HOME}/Gemfile
# COPY Gemfile.lock /${APP_HOME}/Gemfile.lock
RUN bundle install
COPY . /${APP_HOME}

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
