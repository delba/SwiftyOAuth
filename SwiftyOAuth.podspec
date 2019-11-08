Pod::Spec.new do |s|
  s.name          = 'SwiftyOAuth'
  s.version       = '2.0'
  s.license       = { :type => 'MIT' }
  s.homepage      = 'https://github.com/delba/SwiftyOAuth'
  s.author        = { 'Damien' => 'damien@delba.io' }
  s.summary       = "A small OAuth library with a built-in set of providers"
  s.source        = { :git => 'https://github.com/delba/SwiftyOAuth.git', :tag => s.version }
  s.swift_version = '5.0'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Source/**/*.{swift,h}'

  s.requires_arc = true
end
