# frozen_string_literal: true

require_relative 'lib/amdgpu_fan/version'

Gem::Specification.new do |s|
  s.name        = 'amdgpu_fan'
  s.version     = AmdgpuFan::VERSION
  s.summary     =
    'A CLI to view and set fan speeds for AMD graphics cards running on the '\
    'open source amdgpu Linux driver'
  s.description = 'A CLI for interacting with the amdgpu Linux driver'
  s.authors     = ['Kevin McCormack']
  s.email       = 'harlemsquirrel@gmail.com'
  s.executables << 'amdgpu_fan'
  s.files       = Dir['bin/*', 'config/*', 'lib/**/*', 'README.md']
  s.homepage    =
    'https://github.com/HarlemSquirrel/amdgpu-fan-rb'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 3.1.0'

  s.add_runtime_dependency 'async', '~> 2.0'
  s.add_runtime_dependency 'thor', '~> 1.0'

  s.add_development_dependency 'pry', '~> 0.14'
  s.add_development_dependency 'rspec', '~> 3.10'
  s.add_development_dependency 'rubocop', '~> 1.24'
  s.add_development_dependency 'rubocop-rspec', '~> 2.7'
  s.metadata = {
    'rubygems_mfa_required' => 'true'
  }
end
