# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :deploy_to, '/var/www/sdgapi/production'
set :branch, ENV['branch'] || 'master'
set :rails_env, 'production'
# set :domain, '192.168.100.160'
set :domain, '192.168.100.156'
