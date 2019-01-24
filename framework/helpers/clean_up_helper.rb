class CleanUpHelper
  def self.kill_automation_related_entities
    pids_to_kill = (chromedriver_and_browser_pids + geckodriver_and_browser_pids).delete_if(&:empty?)
    return if pids_to_kill.empty?
    pids_to_kill.each { |pid| kill_pid pid }
  end

  def self.headless_pids
    `ps -aux | grep Xvfb | grep -v grep | awk '{print $2}'`.split("\n")
  end

  def self.chromedriver_and_browser_pids
    chromedriver_pids = `ps -aux | grep chromedriver | grep -v grep | awk '{print $2}'`.split("\n")
    browser_pids = []
    chromedriver_pids.each do |chromedriver_pid|
      browser_pid = `ps -o ppid= -o pid= -A | awk '$1 == #{chromedriver_pid}{print $2}'`.strip
      browser_pids << browser_pid unless browser_pid.empty?
    end
    chromedriver_pids + browser_pids
  end

  def self.geckodriver_and_browser_pids
    geckodriver_pids = `ps -aux | grep geckodriver | grep -v grep | awk '{print $2}'`.split("\n")
    browser_pids = []
    geckodriver_pids.each do |chromedriver_pid|
      browser_pid = `ps -o ppid= -o pid= -A | awk '$1 == #{chromedriver_pid}{print $2}'`.strip
      browser_pids << browser_pid unless browser_pid.empty?
    end
    geckodriver_pids + browser_pids
  end

  def self.kill_pid(pid)
    MyLogger.log("kill -9 #{pid}(#{get_pid_command(pid)})")
    `kill -9 #{pid} 2>&1`
    sleep 1
  end

  def self.get_pid_command(pid)
    `ps -p #{pid} -o comm=`.strip
  end
end
