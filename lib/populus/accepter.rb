require 'populus/remote_runner'
require 'populus/node'

module Populus
  class Accepter
    # TODO: validators
    class Base
      attr_accessor :condition, :runner, :metadata

      def initialize(cond: nil, runs: nil, metadata: {})
        self.condition = cond
        self.runner = runs
        self.metadata = metadata
      end

      def type?(t)
        current_type = self.class.name.downcase
          .split('::')
          .last
        current_type == t
      end

      def accept(data)
        if condition[data]
          Populus.logger.debug "Condition judged true: #{data.inspect}"
          instance_exec(data, &runner)
          return true
        else
          Populus.logger.debug "Condition judged false: #{data.inspect}"
          return false
        end
      end

      def on(hostname, &run_it)
        be = Node.registry[hostname]
        if be
          RemoteRunner.new(be, &run_it)
        else
          Populus.logger.warn "Not found host: #{hostname}. Skip."
        end
      end
    end

    class Event < Base
      def has_name?(name)
        metadata[:name] == name
      end

      def create_thread
        _name = metadata[:name]
        Populus.logger.debug "Create thread: consul watch -type event -name #{_name}"
        Populus::WatchThread.consul_watch('-type', 'event', '-name', _name)
      end
    end
  end
end
