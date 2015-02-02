#require  Sidekiq original launcher
require 'sidekiq/launcher'

#require cron poller
require 'sidekiq/cron/poller'

# For Cron we need to add some methods to Launcher
# so look at the code bellow.
#
# we are creating new cron poller instance and
# adding start and stop commands to launcher
module Sidekiq
  class Launcher

    #Add cron poller to launcher
    attr_reader :cron_poller


    #remember old initialize
    alias_method :old_initialize, :initialize

    #add cron poller and execute normal initialize of Sidekiq launcher
    def initialize(options)
      if options[:cron_poller].nil? || options[:cron_poller]
        @cron_poller  = Sidekiq::Cron::Poller.new
      end
      old_initialize options
    end


    #remember old run
    alias_method :old_run, :run

    #execute normal run of launcher and run cron poller
    def run
      old_run
      if cron_poller
        cron_poller.async.poll(true)
      end
    end


    #remember old stop
    alias_method :old_stop, :stop

    #execute normal stop of launcher and stop cron poller
    def stop
      if cron_poller
        cron_poller.async.terminate if poller.alive?
      end
      old_stop
    end

  end
end
