module WirisPlugin
include  Wiris
    class TimerProxy < Timer
    include Wiris

        attr_accessor :timerTask
        attr_accessor :isTimeout
        def initialize(ms, runOnce, task)
            super(ms)
            @isTimeout = runOnce
            @timerTask = task
        end
        def run()
            if @isTimeout
                stop()
            end
            @timerTask::run(self)
        end

    end
end
