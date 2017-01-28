require "yaml"

DRY_RUN = true

class Interface
  attr_reader :message

  def initialize(message)
    @message = message
  end

  def error
    puts colorize(31, "💥 #{message}")
  end

  def heading
    puts colorize(36, "==== #{message} ===")
  end

  def subheading
    puts colorize(36, "   #{message}")
  end

  def info
    puts colorize(34, message)
  end

  private

  def colorize(color_code, message)
    "\e[#{color_code}m#{message}\e[0m"
  end
end

class Hooks
  def pre_deploy

  end

  def post_deploy
    Dir.chdir(PRE_HOOK_DIR)
    Dir.glob("*.rb").each do |file|
      execute_module File.join(PRE_HOOK_DIR, file)
    end
  end

  private

  def execute_module(filename)
    system(filename)
  end
end

class Config
  CONFIG_FILE = "deploy_bot.yml"
  attr_reader :file

  def initialize
    # self_path = File.expand_path File.dirname(__FILE__)
    @file = YAML.load_file(File.join(Dir.pwd, CONFIG_FILE))
  end

  def app_name_for(environment)
    environments[environment]["app_name"]
  end

  def environments
    file["environments"]
  end

  def environment_names
    environments.keys
  end

  def deploy_groups
    file["deploy_groups"]
  end

  def deploy_group_names
    file["deploy_groups"].keys
  end

  def pre_deploy_hooks_for(environment)
    environments[environment]["pre_deploy_hooks"]
  end

  def post_deploy_hooks_for(environment)
    environments[environment]["post_deploy_hooks"]
  end

  def remote_name_for(environment)
    environments[environment]["remote_name"]
  end
end

class Deploy
  def initialize
    @config = Config.new
  end

  def run
    @config.environment_names.each do |env|
      deploy_environment(env)
    end
  end

  def deploy_environment(env)
    pre_hooks = @config.pre_deploy_hooks_for(env)
    post_hooks = @config.post_deploy_hooks_for(env)

    if pre_hooks != nil
      Interface.new("Running pre-deploy hooks").heading
      run_hooks(pre_hooks, env, :pre_deploy)
    end

    Interface.new("Starting deploy to #{env}").heading
    push_to_heroku @config.remote_name_for(env)

    if post_hooks != nil
      Interface.new("Running post-deploy hooks").heading
      run_hooks(post_hooks, env, :post_deploy)
    end
  end

  def run_hook(hook, env, hook_type)
    # self_path = File.expand_path File.dirname(__FILE__)
    path = File.join("./hooks", hook)
    app_name = @config.app_name_for(env)
    remote_name = @config.remote_name_for(env)

    execute_shell("ruby #{path} #{env} #{hook_type} #{app_name} #{remote_name}")
  end

  def run_hooks(hooks, env, hook_type)
    hooks.each do |hook|
      run_hook(hook, env, hook_type)
    end
  end

  def execute_shell(command)
    if DRY_RUN
      puts command
    else
      if !system(command)
        puts "Error executing command: #{command}"
        return
      end
    end
  end

  def display_help
    puts "The following params are supported by this script:"
    puts "   -m [on|off]  Turn maintenance mode on or off for production. On is default."
    puts "   -t [demo|production]  Target certain environments instead of both. Both are deployed by default."
    puts "   -q [yes|no]  Don't announce deploy on slack. (no is default)"
    puts "   -h  Show help. You're already here, dummy!"
  end

  def migrate_db
    execute_shell("heroku run rake data:migrate --app #{APP_NAME}")
  end

  def push_to_heroku(remote_name)
    execute_shell("git push #{remote_name} master")
  end

  def start
    # Prompt before running
    printf "🚨  You are deploying to $TARGET! 🚨\n\n"
    # read -n1 -r -p "Press any key to continue or CTRL+C to exit..." key
    printf "\n"

    echo "${BLUE}🎉   Deploy to $TARGET finished! Tagged as $NEW_TAG${NC}"
  end
end

Deploy.new.run
