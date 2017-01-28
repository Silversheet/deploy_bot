#
# Makes sure master is being deployed
#

class DeployHook
  attr_reader :environment, :hook

  def initialize(environment, hook)
    @environment = environment
    @hook = hook
  end

  def run
    current_branch = `git rev-parse --abbrev-ref HEAD`

    if current_branch.delete!("\n") != "master"
      puts "⛔️ You are attempting to deploy #{current_branch}. Please switch to master.\n"
      exit
    else
      puts "You are deploying #{current_branch} branch to #{environment}.\n"
    end
  end
end

DeployHook.new(ARGV[0], ARGV[1]).run
