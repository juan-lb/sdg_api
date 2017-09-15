source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.0.3'
gem 'mysql2', '>= 0.3.18', '< 0.5'
gem 'unicorn'
gem 'jbuilder', '~> 2.5'
gem 'whenever', require: false
gem 'listen', '~> 3.0.5'
gem 'net-sftp'
gem 'carrierwave'
gem 'composite_primary_keys'

group :development, :test do
  gem 'hirb'
  gem 'pry'
  gem 'byebug', platform: :mri
end

group :development do
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'rails-controller-testing'
  gem 'webmock'
  gem 'simplecov', require: false
  gem 'minitest-stub_any_instance', '~> 1.0', '>= 1.0.1'
end
