module ProcessHelpers
  def process_running? pid
    begin
      Process.getpgid process.pid
      true
    rescue Errno::ESRCH
      false
    end
  end
end
