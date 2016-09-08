require "json"
require "http/client"

module Cobot::Plugins::Github
  extend self

  def bind(bot)
    bind_pull_request_info(bot)
  end

  PATTERN = /(?:[ ]+|^)([a-zA-Z]+\/[a-zA-Z]+|)#(\d{1,5})\b/
  private def bind_pull_request_info(bot)
    bot.on("PRIVMSG", message: PATTERN) do |msg, match|
      pull_requests = msg.message.as(String).scan PATTERN
      pull_requests.each do |pr|
        repo = pr[1].blank? ? "gapfish/gapfish" : pr[1]
        nr = pr[2]
        pull_request_info(repo, nr, msg)
      end
    end
  end

  private def pull_request_info(repo, nr, msg)
    pull_request = Api.pull_request(repo, nr)
    msg.reply "#{pull_request}" unless pull_request.nil?
  end

  class Api
    # format: https://developer.github.com/v3/pulls/#get-a-single-pull-request
    def self.pull_request(repo, nr)
      url = "#{api_url}/repos/#{repo}/pulls/#{nr}"
      res = HTTP::Client.get(url, headers: headers)
      return if res.status_code >= 300
      # JSON.parse(res.body)
      PullRequest.from_json(res.body)
    end

    private def self.token
      ENV["GITHUB_TOKEN"]
    end

    private def self.headers
      HTTP::Headers{
        "Authorization" => "token #{token}",
        "Accept"        => "application/vnd.github.v3+json",
      }
    end

    private def self.api_url
      "https://api.github.com"
    end
  end

  class PullRequest
    JSON.mapping({
      html_url: String,
      title: String,
      additions: UInt64,
      deletions: UInt64
    })

    def to_s(io)
      io << "#{html_url} #{title} (+#{additions}, -#{deletions})"
    end
  end

end
