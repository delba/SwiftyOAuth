Pod::Spec.new do |s|
  s.name         = "SwiftyOAuth"
  s.version      = "0.3.6"
  s.license      = { :type => "MIT" }
  s.homepage     = "https://github.com/delba/SwiftyOAuth"
  s.author       = { "Damien" => "damien@delba.io" }
  s.summary      = "A small OAuth library with a built-in set of providers"
  s.source       = { :git => "https://github.com/delba/SwiftyOAuth.git", :tag => "v0.3.6" }

  s.ios.deployment_target = "8.0"

  s.source_files = "Source/**/*.{swift,h}"

  s.requires_arc = true
end
