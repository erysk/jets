require 'logger'

module Jets::Util
  # Ensures trailing slash
  # Useful for appending a './' in front of a path or leaving it alone.
  # Returns: '/path/with/trailing/slash/' or './'
  @@root = nil
  def root
    return @@root if @@root
    @@root = ENV['PROJECT_ROOT'].to_s
    @@root = '.' if @@root == ''
    @@root = "#{@@root}/" unless @@root.ends_with?('/')
    @@root
  end

  @@logger = nil
  def logger
    return @@logger if @@logger
    @@logger = Logger.new($stderr)
  end

  # Load all application base classes and project classes
  def boot
    require_application_base_classes
    # being selective enough to not include app/views
    require_project_classes %w[app/controllers app/jobs app/models lib]
  end

  def require_application_base_classes
    application_files = %w[
      app/controllers/application_controller
      app/jobs/application_job
      app/models/application_record
      app/models/application_item
    ]
    application_files.each do |p|
      path = "#{Jets.root}#{p}.rb"
      require path if File.exist?(path)
    end
  end

  def require_project_classes(folders)
    folders.each do |folder|
      pattern = "#{Jets.root}#{folder}/**/*" # #{Jets.root}/lib/**/**
      require_files(pattern)
    end
  end

  def require_files(pattern)
    Dir.glob(pattern).each do |path|
      next unless File.file?(path) && File.extname(path) == '.rb'
      require path
    end
  end

  def env
    Jets.config.env
  end

  def config
    Jets::Config.new.settings
  end

  @@tmpdir = nil
  def tmpdir
    @@tmpdir ||= "/tmp/jets/#{config.project_name}".freeze
  end
end
