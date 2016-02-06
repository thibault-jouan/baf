module ExitHelpers
  def trap_exit
    yield
  rescue SystemExit
  end

  def trap_exit!
    yield
  rescue SystemExit => e
    fail "given block exited with #{e.status} status code"
  end
end
