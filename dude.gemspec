$:.unshift File.expand_path("../lib", __FILE__)
require "megam/version"

Gem::Specification.new do |gem|
  gem.name = "dude"
  gem.version = Megam::VERSION
  gem.author = "Kishore"
  gem.email = "nkishore@megam.co.in"
  gem.homepage = "http://megam.co/"
  gem.summary = "CLI to automate setting up workarea."
  gem.description = "Command-line tool to setup your work area quickly and easily. Automate the repetitive steps that you would use to install. Read http://blog.megam.co/archives/485"
  gem.license = "Apache V2"
  gem.extra_rdoc_files = ["README.md", "LICENSE" ]
  gem.post_install_message = <<-MESSAGE
! The `dude` gem has been installed. 
! To run it, setup your work_area, and run dude -i <workarea>/install.rb.
! For detail instructions : https://github.com/indykish/dude.git
MESSAGE

  gem.add_dependency "mixlib-config", ">= 1.1.2"
  gem.add_dependency "mixlib-cli", "~> 1.3.0"
  gem.add_dependency "mixlib-log", ">= 1.3.0"
  gem.add_dependency "mixlib-authentication", ">= 1.3.0"
  gem.add_dependency "mixlib-shellout"
  gem.add_dependency "hashie"
  gem.add_dependency "ruby-progressbar"
  gem.add_dependency "highline", ">= 1.6.9"

  %w(rdoc sdoc rake rack rspec_junit_formatter).each { |s| gem.add_development_dependency s}
  %w(rspec-core rspec-expectations rspec-mocks).each { |s| gem.add_development_dependency s, ">= 2.13.0" }

  gem.bindir = "bin"
  gem.executables = %w( dude )

  gem.require_path = 'lib'
  gem.files = %w(Rakefile LICENSE README.md) + Dir.glob("{lib,tasks,spec}/**/*")

end
