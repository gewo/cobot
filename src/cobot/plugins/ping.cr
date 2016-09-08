module Cobot::Plugins::Ping
  extend self

  def bind(bot)
    bot.on("PRIVMSG", message: /!ping/) do |msg|
      msg.reply "*plonk*"
    end
  end
end
