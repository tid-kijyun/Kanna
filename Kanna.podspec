Pod::Spec.new do |s|
  s.name             = "Kanna"
  s.version          = "2.0.0"
  s.summary          = "Kanna is an XML/HTML parser for iOS/Mac OS X."
  s.homepage         = "https://github.com/tid-kijyun/Kanna"
  s.license          = 'MIT'
  s.author           = { "Atsushi Kiwaki" => "tid.develop@gmail.com" }
  s.source           = { :git => "https://github.com/tid-kijyun/Kanna.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/_tid_'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = "9.0"
  s.watchos.deployment_target = "2.0"
  s.requires_arc = true

  s.source_files  = ['Sources/**/*.swift', 'Sources/**/*.h']
  s.libraries     = 'xml2'
  s.xcconfig      = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }
end
