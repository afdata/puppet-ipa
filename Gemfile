source 'https://rubygems.org'

if ENV.key?('PUPPET_VERSION')
  puppetversion = "= #{ENV['PUPPET_VERSION']}"
else
  puppetversion = ['~> 3.8.0']
end

gem 'rake', '> 0.9'
gem 'puppet-lint', '> 1.1.0'
gem 'rspec-puppet', '~> 2.6.9'
gem 'puppetlabs_spec_helper'
gem 'json', '~> 1.8.5'
gem 'puppet', puppetversion
