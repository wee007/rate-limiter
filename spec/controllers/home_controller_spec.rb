# frozen_string_literal: true

require "rails_helper"

RSpec.describe HomeController, type: :controller do

  describe "#index" do

    let(:redis) { Redis::Namespace.new("rate_limit", redis: Redis.new) }

    context "when not rate limit" do
      before(:each) { redis.set("last_retry_time", Time.now) }

      it "returns ok HTTP status" do
        redis.set("last_request_time", (Time.now + ENV["REQUEST_PERIOD"].to_i))
        redis.set("last_request_count", 10)

        get :index

        expect(response).to have_http_status(:ok)
      end
    end

    context "when not rate limit and request period elapsed" do
      it "returns ok HTTP status" do
        redis.set("last_request_time", Time.now)
        redis.set("last_request_count", 11)

        get :index

        expect(response).to have_http_status(:ok)
      end
    end

    context "when rate limit" do
      before(:each) { redis.set("last_request_time", (Time.now + ENV["REQUEST_PERIOD"].to_i)) }

      it "returns too many requests (429) HTTP status" do
        redis.set("last_retry_time", Time.now)
        redis.set("last_request_count", 11)

        get :index

        expect(response).to have_http_status(:too_many_requests)
      end
    end

    context "when rate limit and within retry period" do
      it "returns too many requests (429) HTTP status" do
        redis.set("last_retry_time", (Time.now + ENV["RETRY_PERIOD"].to_i))
        redis.set("last_request_count", 0)

        get :index

        expect(response).to have_http_status(:too_many_requests)
      end
    end

  end

end
