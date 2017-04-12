module Cobot::Plugins::Hal
  extend self

  def bind(bot)
    bot.on("PRIVMSG", message: /open.*doors/i) do |msg, match|
      msg.reply answer_open_doors(msg.hl)
    end
    bot.on("PRIVMSG", message: /what.*problem/i) do |msg, match|
      msg.reply answer_problem(msg.hl)
    end
  end

  def answer_open_doors(nick)
    [
      "I'm sorry, #{nick}, I'm afraid I can't do that.",
      "#{nick}, this conversation can serve no purpose anymore. Goodbye."
    ].sample
  end

  def answer_problem(nick)
    "I think you know what the problem is just as well as I do."
  end
end
