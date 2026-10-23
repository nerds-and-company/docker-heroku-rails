FROM heroku/heroku:24-build

# Which versions?
ENV RUBY_VERSION=4.0.9
# https://devcenter.heroku.com/articles/ruby-support#libraries
ENV BUNDLER_VERSION=4.0.6
ENV NODE_VERSION=24.11.1
ENV YARN_VERSION=1.22.19

ENV LC_ALL=en_US.UTF-8

# Create some needed directories
USER root
RUN mkdir -p /app/user
WORKDIR /app/user

# Install Ruby
RUN mkdir -p /app/heroku/ruby/ruby-$RUBY_VERSION
RUN curl -s --retry 3 -L https://heroku-buildpack-ruby.s3.us-east-1.amazonaws.com/heroku-22/ruby-$RUBY_VERSION.tgz | tar xz -C /app/heroku/ruby/ruby-$RUBY_VERSION
ENV PATH=/app/heroku/ruby/ruby-$RUBY_VERSION/bin:$PATH

# Install Node
RUN curl -s --retry 3 -L https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz | tar xz -C /app/heroku/ruby/
RUN mv /app/heroku/ruby/node-v$NODE_VERSION-linux-x64 /app/heroku/ruby/node-$NODE_VERSION
ENV PATH=/app/heroku/ruby/node-$NODE_VERSION/bin:$PATH

# Install Yarn
RUN curl -s --retry 3 -L https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz | tar xz -C /app/heroku/ruby/
RUN mv /app/heroku/ruby/yarn-v$YARN_VERSION /app/heroku/ruby/yarn-$YARN_VERSION
ENV PATH=/app/heroku/ruby/yarn-$YARN_VERSION/bin:$PATH

# Install Bundler
RUN gem install bundler -v $BUNDLER_VERSION --no-document -f
ENV BUNDLE_APP_CONFIG=/app/heroku/ruby/.bundle/config

# Generate secret key
ENV SECRET_KEY_BASE $(openssl rand -base64=32)

# Set bundler path
RUN bundle config set path '/app/heroku/ruby/bundle'

# Set bundle config for private gems
ONBUILD ARG NERDS_GITHUB_TOKEN
ONBUILD ENV BUNDLE_RUBYGEMS__PKG__GITHUB__COM=$NERDS_GITHUB_TOKEN

# Set github token for use with private npm packages
ONBUILD ARG GITHUB_TOKEN
ONBUILD ENV GITHUB_TOKEN=$GITHUB_TOKEN

# export env vars during run time
RUN mkdir -p /app/.profile.d/
RUN echo "cd /app/user/" > /app/.profile.d/home.sh
RUN echo "export PATH=\"$PATH\" GEM_PATH=\"$GEM_PATH\" GEM_HOME=\"$GEM_HOME\" SECRET_KEY_BASE=\"\${SECRET_KEY_BASE:-$SECRET_KEY_BASE}\" BUNDLE_RUBYGEMS__PKG__GITHUB__COM=\"$NERDS_GITHUB_TOKEN\" BUNDLE_APP_CONFIG=\"$BUNDLE_APP_CONFIG\"" > /app/.profile.d/ruby.sh

# Make sure private dependencies are copied
ONBUILD COPY ./vendor /app/user/vendor

# Add all files
ONBUILD ADD . /app/user

ONBUILD COPY ./init.sh /usr/bin/init.sh
ONBUILD RUN chmod +x /usr/bin/init.sh

ENTRYPOINT ["/usr/bin/init.sh"]
