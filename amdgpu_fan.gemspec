# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'amdgpu_fan'
  s.version     = '0.5.2'
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

  s.add_runtime_dependency 'thor', '~> 1.0'

  s.add_development_dependency 'pry'
  s.add_development_dependency 'rspec'
end
