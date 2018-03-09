Gem::Specification.new do |s|
  s.name = 'british_suntimes'
  s.version = '0.2.0'
  s.summary = 'Generates the British sunrise and sunset times.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/british_suntimes.rb']
  s.add_runtime_dependency('dynarex', '~> 1.7', '>=1.7.29')
  s.add_runtime_dependency('geocoder', '~> 1.4', '>=1.4.6')
  s.add_runtime_dependency('chronic_cron', '~> 0.3', '>=0.3.7')
  s.add_runtime_dependency('RubySunrise', '~> 0.3', '>=0.3.1')  
  s.signing_key = '../privatekeys/british_suntimes.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/british_suntimes'
end
