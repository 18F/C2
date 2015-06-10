if defined?(Bullet)
  # https://github.com/flyerhzm/bullet#configuration
  Bullet.enable = true
  Bullet.console = true
  Bullet.rails_logger = true
  Bullet.stacktrace_includes = [ 'omniauth-myusa' ]
end
