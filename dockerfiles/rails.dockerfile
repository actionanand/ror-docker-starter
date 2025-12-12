FROM ruby:3.2-alpine

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    yarn \
    git \
    curl \
    gcompat

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY src/Gemfile* ./

# Install gems
RUN bundle install --jobs 4 --retry 3

# Copy application code
COPY src .

# Precompile assets (optional, adjust as needed)
RUN bundle exec rails assets:precompile 2>/dev/null || true

# Create tmp directories
RUN mkdir -p tmp/pids tmp/cache tmp/sockets

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
