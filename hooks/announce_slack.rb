class DeployHook
  attr_reader :app_name, :environment, :hook, :remote_name

  SLACK_URL=""
  TEST_SLACK_URL=""

  def initialize(environment, hook, app_name, remote_name)
    @environment = environment
    @hook = hook
    @app_name = app_name
    @remote_name = remote_name
  end

  def run
    message = "A deploy has been pushed to #{environment} 🎉"
    system('curl -X POST -H \'Content-type: application/json\' --data "{\"text\": \"$MESSAGE\"}" $SLACK_URL > /dev/null 2>&1')
  end
end

DeployHook.new(ARGV[0], ARGV[1], ARGV[2], ARGV[3]).run
