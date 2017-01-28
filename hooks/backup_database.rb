class DeployHook
  attr_reader :app_name, :environment, :hook, :remote_name

  def initialize(environment, hook, app_name, remote_name)
    @environment = environment
    @hook = hook
    @app_name = app_name
    @remote_name = remote_name
  end

  def run
    system "heroku pg:backups:capture --app #{APP_NAME}"
  end
end

DeployHook.new(ARGV[0], ARGV[1], ARGV[2], ARGV[3]).run
