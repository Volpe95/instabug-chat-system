class Publisher
    #FixME -> Should be implmeneted in a cleaner way.
    def self.publish(exchange, message = {})
      @@connection ||= $bunny.tap do |c|
        c.start
      end
      @@channel ||= @@connection.create_channel
      @@fanout ||= @@channel.fanout("chatsystem.#{exchange}")
      @@queue ||= @@channel.queue("chatsystem.#{exchange}", durable: true).tap do |q|
        q.bind("chatsystem.#{exchange}")
      end
      @@fanout.publish(message)
    end
  end
  