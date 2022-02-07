Gem::Specification.new do |s|
  s.name = 'british_suntimes'
  s.version = '0.5.0'
  s.summary = 'Generates the British sunrise and sunset times.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/british_suntimes.rb']
  s.add_runtime_dependency('dynarex', '~> 1.9', '>=1.9.2')
  s.add_runtime_dependency('geocoder', '~> 1.7', '>=1.7.3')
  s.add_runtime_dependency('chronic_cron', '~> 0.7', '>=0.7.1')
  s.add_runtime_dependency('RubySunrise', '~> 0.3', '>=0.3.3')
  s.add_runtime_dependency('subunit', '~> 0.8', '>=0.8.5')
  s.add_runtime_dependency('human_speakable', '~> 0.2', '>=0.2.0')  
  s.signing_key = '../privatekeys/british_suntimes.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'digital.robertson@gmail.com'
  s.homepage = 'https://github.com/jrobertson/british_suntimes'
end
