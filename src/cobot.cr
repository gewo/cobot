require "CrystalIrc"
require "./cobot/*"
require "./cobot/plugins/*"

::VERBOSE = true # for CrystalIrc

module Cobot
  def channels
    ENV.fetch("IRC_CHANNELS", "#cobot").split(",")
  end

  def start
    bot = CrystalIrc::Bot.new(
      ip:           ENV.fetch("IRC_SERVER", "irc.freenode.net"),
      nick:         ENV.fetch("IRC_NICK", "cobot"),
      pass:         ENV.fetch("IRC_PASSWORD", nil),
      port:         ENV.fetch("IRC_PORT", "6697").to_u16,
      read_timeout: ENV.fetch("IRC_READ_TIMEOUT", "300").to_u16
    )

    Plugins::Github.bind(bot)
    Plugins::Ping.bind(bot)
    Plugins::Hal.bind(bot)

    bot.connect.on_ready do
      channels.each do |chan|
        bot.join chan unless chan.empty?
      end
    end

    loop do
      begin
        bot.gets do |m|
          break if m.nil?
          STDERR.puts "[#{Time.now}] #{m}"
          spawn { bot.handle(m.as(String)) }
        end
      rescue IO::Timeout
        STDERR.puts "[#{Time.now}] IO timeout, exiting..."
        exit 42
      end
    end
  end

  extend self
end

Cobot.start
