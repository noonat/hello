require 'rake/clean'

SRCS = FileList['examples/**/*.hx', 'hello/**/*.hx']

task :default => 'bin/debug.swf'

directory 'bin'

file 'bin/debug.swf' => ['bin'] + SRCS do |task|
  sh [
    'haxe',
    '-debug',
    '-D debug',
    '-D fdb',
    '--flash-strict',
    '--flash-use-stage',
    '-swf-version 10',
    "-swf #{task.name}",
    '-cp .',
    '-resource examples/queens/assets/assets.xml@assets.xml',
    '-main examples.queens.Queens'
  ].join(' ')
end
CLEAN << 'bin/debug.swf'

file 'bin/release.swf' => ['bin'] + SRCS do |task|
  sh [
    'haxe',
    '-D release',
    '--flash-strict',
    '--flash-use-stage',
    '-swf-version 10',
    "-swf #{task.name}",
    '-cp .',
    '-resource examples/queens/assets/assets.xml@assets.xml',
    '-main examples.queens.Queens'
  ].join(' ')
end
CLEAN << 'bin/release.swf'

task :fdb do
  Debugger.new.run
end

task :server do
  sh 'ruby server.rb'
end

task :test do
  sh 'haxe -cp src -cp test -neko test.n -main Test'
  sh 'neko test.n'
  rm 'test.n'
end

class Debugger
  def initialize
    $stdout.sync = true
    @line_triggers = {
      "Player connected; session starting." => proc { trigger :connected },
      "Player session terminated" => proc { trigger :connect },
      "Failed to connect; session timed out." => proc { trigger :connect }
    }
    @triggers = {
      "(fdb) " => proc { trigger :idle }
    }
    @read_buffer = ""
    @write_buffer = ""
    @state = :starting
  end
  
  def run
    open('|fdb', 'w+') do |handle|
      @pipe = handle
      while true do
        IO.select [@pipe], [], [@pipe]
        
        # read
        begin
          data = @pipe.read_nonblock 1024
          print data
          @read_buffer += data
        rescue Errno::EAGAIN, Errno::EWOULDBLOCK
          nil
        end
        
        # parse
        until (i = @read_buffer.index("\n")) == nil
          line, @read_buffer = @read_buffer.split("\n", 2)
          # puts line
          if (trigger = @line_triggers[line]) || (trigger = @triggers[line])
            trigger.call 
          end
        end
        if (trigger = @triggers[@read_buffer])
          @read_buffer = ""
          trigger.call
        end
        
        # write
        unless @write_buffer.empty?
          length = @pipe.write_nonblock @write_buffer
          @write_buffer.slice! length..-1 if length > 0
        end
      end
    end
  end
  
  def trigger(type)
    case type
    when :connect
      write "run"
      @state = :connecting
    when :connected
      @state = :connected
    when :continue
      write "continue"
      @state = :running
    when :idle
      case @state
      when :starting then trigger :connect
      when :connected then trigger :continue
      end
    else
      raise "Unknown trigger type #{type}"
    end
  end

  def write(command)
    print command, "\n"
    @pipe.write command + "\n"
  end
end
