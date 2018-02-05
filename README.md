# Rate Limiter

## Context

The app is built using Ruby 2.5.0 and Rails 5.1.4.

A rate limiter that returns a text string "ok" when a requester hits the root URL until the request limit (e.g. 100) is reached within the request period (e.g. 1 hour) which will return a 429 (too many requests) HTTP status with the text "Rate limit exceeded. Try again in #{n} seconds". The requester will continue seeing the rate limit message with the count down indicator until the retry period (e.g. 30 seconds) is reached.

The request count, request time and retry time values are stored in Redis and are used to determine the rate limit.

## Getting Started

The request limit, request period and retry period are configurable in the `.env` file.

The redis keys are prefixed with `rate_limit` (e.g. rate_limit:last_request_count).

Go to the root URL (e.g. localhost:3000) to see the rate limiter in action! Hit the URL to make the HTTP request.

Run test specs via `rspec` and coverage report will be produced as well.
