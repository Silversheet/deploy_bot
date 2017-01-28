class DeployHook
  attr_reader :app_name, :environment, :hook, :remote_name, :migrate_faster

  def initialize(environment, hook, app_name, remote_name)
    @environment = environment
    @hook = hook
    @app_name = app_name
    @remote_name = remote_name

    @migrate_faster = environment == "production" ? true : false
  end

  def run
    performance_dyno = ""

    if migrate_faster
      performance_dyno = "--size=performance-l"
    end

    system "heroku run #{performance_dyno} rake data:migrate --app #{app_name}"
  end
end

DeployHook.new(ARGV[0], ARGV[1], ARGV[2], ARGV[3]).run
