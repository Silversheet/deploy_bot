class DeployHook
  attr_reader :app_name, :environment, :hook, :remote_name

  def initialize(environment, hook, app_name, remote_name)
    @environment = environment
    @hook = hook
    @app_name = app_name
    @remote_name = remote_name
  end

  def run
    if hook == "pre-deploy"
      turn_on_maintenance
    else
      turn_off_maintenance
    end
  end

  private

  def turn_on_maintenance
    puts "==> 🚧  Turning maintenance mode on\n"
    system "heroku maintenance:on --app #{app_name}"
  end

  def turn_off_maintenance
    puts "==> 🚦  Turning maintenance mode off\n"
    system "heroku maintenance:off --app #{app_name}"
  end
end

DeployHook.new(ARGV[0], ARGV[1], ARGV[2], ARGV[3]).run
