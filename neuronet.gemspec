Gem::Specification.new do |s|
  ## INFO ##
  s.name     = 'neuronet'
  s.version  = '7.0.230219'
  s.homepage = 'https://github.com/carlosjhr64/neuronet'
  s.author   = 'CarlosJHR64'
  s.email    = 'carlosjhr64@gmail.com'
  s.date     = '2023-02-20'
  s.licenses = ['MIT']
  ## DESCRIPTION ##
  s.summary  = <<~SUMMARY
    Library to create neural networks.
  SUMMARY
  s.description = <<~DESCRIPTION
    Library to create neural networks.
    
    This is primarily a math project
    meant to be used to investigate the behavior
    of different small neural networks.
  DESCRIPTION
  ## FILES ##
  s.require_paths = ['lib']
  s.files = %w[
    README.md
    lib/neuronet.rb
  ]
  
  ## REQUIREMENTS ##
  s.add_development_dependency 'colorize', '~> 0.8', '>= 0.8.1'
  s.add_development_dependency 'parser', '~> 3.2', '>= 3.2.1'
  s.add_development_dependency 'rubocop', '~> 1.45', '>= 1.45.1'
  s.add_development_dependency 'test-unit', '~> 3.5', '>= 3.5.7'
  s.requirements << 'git: 2.30'
end
