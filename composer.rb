def remove_gem(*names)
  names.each do |name|
    gsub_file 'Gemfile', /gem '#{name}'.*\n/, ''
  end
end

def replace_myapp(file)
  gsub_file file, /myapp/, app_name, verbose: false
end

def get_remote(src, dest = nil)
  dest ||= src

  if ENV['RAILS_TEMPLATE_DEBUG'].present?
    repo = File.join(File.dirname(__FILE__), 'files/')
  else
    repo = 'https://raw.githubusercontent.com/FloHeinle/rails-template/main/files/'
  end

  remote_file = repo + src
  get(remote_file, dest, force: true)
  replace_myapp(dest)
end

def get_remote_dir(names, dir)
  names.each do |name|
    src = File.join(dir, name)
    get_remote(src)
  end
end

def yarn(lib)
  run("yarn add #{lib}")
end

def remove_dir(dir)
  run("rm -rf #{dir}")
end

# gitignore
get_remote('gitignore', '.gitignore')

# postgresql
say 'Applying postgresql...'
get_remote('config/database.yml.example')
get_remote('config/database.yml.example', 'config/database.yml')

# Not included in Ruby from version 3 onwards.
gem 'rexml'

inject_into_file 'Gemfile', before: "gem 'rexml'\n" do <<~EOF
  # Not included in Ruby from version 3 onwards.
  EOF
end

inject_into_file 'Gemfile', after: "group :development do\n" do <<-EOF
  # Automatically run corresponding tests when files are saved.
  gem 'guard'
  gem 'guard-minitest'
  EOF
end

inject_into_file 'Gemfile', after: "group :development, :test do\n" do <<-EOF
  # Adds step-by-step debugging and stack navigation capabilities.
  gem 'pry-byebug'
  EOF
end

after_bundle do
  say 'Stop spring if exists'
  run 'spring stop'
  run 'bundle exec guard init'
  run 'bundle exec guard init minitest'
end

say 'Applying jquery & font-awesome & bootstrap4...'
after_bundle do
  yarn 'bootstrap jquery popper.js @fortawesome/fontawesome-free'

  inject_into_file 'config/webpack/environment.js', after: "const { environment } = require('@rails/webpacker')\n" do <<~EOF

    const webpack = require('webpack')

    environment.plugins.append('Provide', new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery',
      Popper: ['popper.js', 'default']
    }))

    EOF
  end

  inject_into_file 'app/views/layouts/application.html.erb', after: "<body>\n" do <<-EOF
    <%= flash_messages %>

    EOF
  end
end

packs = [ 'application.js' ]
get_remote_dir(packs, 'app/javascript/packs')

helpers = [ 'application_helper.rb' ]
get_remote_dir(helpers, 'app/helpers')

stylesheets = ['application.scss']
get_remote_dir(stylesheets, 'app/javascript/stylesheets')

scripts = ['setup.sh', 'wait-for-postgres.sh']
get_remote_dir(scripts, 'script')

get_remote('.dockerignore')
get_remote('docker-compose.yml')
get_remote('docker-compose.subsystems.yml')
get_remote('Dockerfile')
