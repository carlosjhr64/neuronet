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

  s.homepage = "https://sites.google.com/site/carlosjhr64/rubygems/neuronet"

  readme = File.read('README.txt')
  if readme =~ /^=([^=\n]+)/ then
    s.summary = $1.strip
  else
    raise "No summary??"
  end
  if readme =~ /\n==\s*DESCRIPTION:([^=]*)\n=/i then
    s.description = $1.strip
  else
    raise "No description?"
  end

  s.has_rdoc = true
  s.rdoc_options = ['--main', 'README.txt']
  s.extra_rdoc_files = ['README.txt']

  s.authors = ['carlosjhr64@gmail.com']
  s.email = "carlosjhr64@gmail.com"

  files = []
  $stderr.puts "RBs"
  Find.find('./lib'){|fn|
    if fn=~/\.rb$/ then
      $stderr.puts fn
      files.push(fn)
    end
  }

# if File.exists?('./pngs') then
#   $stderr.puts "PNGs"
#   Find.find('./pngs'){|fn|
#     if fn=~/\.png$/ then
#       $stderr.puts fn
#       files.push(fn)
#     end
#   }
# end

  $stderr.puts "TXTs"
  Find.find('.'){|fn|
    Find.prune if !(fn=='.') && File.directory?(fn)
    if fn=~/\.txt$/ then
      $stderr.puts fn
      files.push(fn)
    end
  }

  s.files = files

# if File.exists?('./bin')
#   $stderr.puts "BINs"
#   executables = []
#   Find.find('./bin'){|fn|
#     if File.file?(fn) then
#       $stderr.puts fn
#       executables.push(fn.sub(/^.*\//,''))
#     end
#   }
#   s.executables = executables
#   s.default_executable = project
# end

# s.add_dependency('xml-simple','~> 1.1')
# s.requirements << 'net/https'

  #s.rubyforge_project = project
end
