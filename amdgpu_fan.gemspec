# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'amdgpu_fan'
  s.version     = '0.0.2'
  s.date        = '2017-11-05'
  s.summary     =
    'A CLI to view and set fan speeds for AMD graphics cards running on the '\
    'open source amdgpu Linux driver'
  s.description = 'A CLI for amdgpu fans'
  s.authors     = ['Kevin McCormack']
  s.email       = 'harlemsquirrel@gmail.com'
  s.executables << 'amdgpu_fan'
  s.files       = Dir['bin/*'] + Dir['lib/**/*'] + Dir['README.md']
  s.homepage    =
    'https://github.com/HarlemSquirrel/amdgpu-fan-rb'
  s.license     = 'MIT'
end
