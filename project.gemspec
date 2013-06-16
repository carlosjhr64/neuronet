require 'date'
require 'find'

project_version = File.expand_path( File.dirname(__FILE__) ).split(/\//).last
project, version = nil, nil
if project_version=~/^(\w+)-(\d+\.\d+\.\d+)$/ then
  project, version = $1, $2
else
  raise 'need versioned directory'
end

spec = Gem::Specification.new do |s|
  s.name = project
  s.version = version
  s.date = Date.today.to_s

  s.homepage = "https://github.com/carlosjhr64/neuronet"
  s.summary = "Library to create neural networks."
  s.description = "Build custom neural networks. 100% 1.9 Ruby."

  s.authors = ['carlosjhr64@gmail.com']
  s.email = 'carlosjhr64@gmail.com'

  files = []
  $stderr.puts 'RBs'
  Find.find('./lib'){|fn|
    if fn=~/\.rb$/ then
      $stderr.puts fn
      files.push(fn)
    end
  }

  files.push('./README.md')

  s.files = files
end
