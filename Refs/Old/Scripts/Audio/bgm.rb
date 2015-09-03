module RPG
  class BGM < AudioFile
    include Seal

    @@play_stack = []

    def play(pos = 0)
      if @name.empty?
        BGM.stop
      else
        @source = Source.new
        @source.stream = Stream.new('Audio/BGM/' + @name)
        @source.gain = @volume / 100.0
        @source.pitch = @pitch / 100.0
        @source.play
        @@play_stack.push(self)
      end
    end

    def replay
      if @source
        @source.play
      else
        play
      end
    end

    def stop
      @source.stop if @source
    end

    class << self
      def stop
        return if @@play_stack.empty?
        bgm = @@play_stack.pop
        bgm.stop
      end

      def fade(time)
        Audio.bgm_fade(time)
      end

      def last
        @@play_stack.empty? ? BGM.new : @@play_stack[-1]
      end
    end

    attr_accessor :pos
  end
end