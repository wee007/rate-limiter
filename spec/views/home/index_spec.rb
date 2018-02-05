# frozen_string_literal: true

require "rails_helper"

RSpec.describe "index", type: :view do

  context "when not rate limit" do
    it "displays ok text" do
      render plain: "ok"

      expect(rendered).to eq "ok"
    end
  end

  context "when rate limit" do
    it "displays the rate limit message" do
      render plain: "Rate limit exceeded. Try again in #{ENV["RETRY_PERIOD"]} seconds"

      expect(rendered).to match /Rate limit exceeded/
    end
  end

end
