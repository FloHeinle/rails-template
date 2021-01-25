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

inject_into_file 'Gemfile', after: "group :test do\n" do <<-EOF
  # One-liners to test common Rails functionality.
  gem 'shoulda'
  EOF
end

inject_into_file 'Gemfile', after: "group :development do\n" do <<-EOF
  # Automatically run corresponding tests and linters when files are saved.
  gem 'guard'
  gem 'guard-minitest'
  gem 'guard-rubocop'
  # Ruby code linter.
  gem 'rubocop'
  gem 'rubocop-rails', require: false
  EOF
end

inject_into_file 'Gemfile', after: "group :development, :test do\n" do <<-EOF
  # Adds step-by-step debugging and stack navigation capabilities.
  gem 'pry-byebug'
  EOF
end

gsub_file 'Gemfile', "gem 'webdrivers'", "gem 'webdrivers', require: false"

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

script = ['setup.sh', 'wait-for-postgres.sh']
get_remote_dir(script, 'script')

test_files = ['application_system_test_case.rb']
get_remote_dir(test_files, 'test')

get_remote('.dockerignore')
get_remote('docker-compose.yml')
get_remote('docker-compose.tdd.yml')
get_remote('docker-compose.subsystems.yml')
get_remote('Dockerfile')
get_remote('Guardfile')
get_remote('.rubocop.yml')

after_bundle do
  say 'Stop spring if exists'
  run 'spring stop'

  inject_into_file 'test/test_helper.rb', after: "end\n" do <<~EOF

    Shoulda::Matchers.configure do |config|
      config.integrate do |with|
        with.test_framework :minitest
        with.library :rails
      end
    end

    EOF
  end
end
