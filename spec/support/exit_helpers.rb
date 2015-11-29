module ExitHelpers
  def trap_exit
    yield
  rescue SystemExit
  end
end
