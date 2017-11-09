Pod::Spec.new do |s|
  s.name             = "Kanna"
  s.version          = "4.0.0"
  s.summary          = "Kanna is an XML/HTML parser for iOS/macOS/watchOS/tvOS and Linux."
  s.homepage         = "https://github.com/tid-kijyun/Kanna"
  s.license          = 'MIT'
  s.author           = { "Atsushi Kiwaki" => "tid.develop@gmail.com" }
  s.source           = { :git => "git@github.com:OlafAndreas/Kanna.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/_tid_'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = "9.0"
  s.watchos.deployment_target = "2.0"
  s.requires_arc = true
  s.preserve_path = 'Modules/*'
  s.source_files  = ['Sources/**/*.swift', 'Sources/**/*.h']
  s.xcconfig      = {
                      'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2',
                      'SWIFT_INCLUDE_PATHS' => '$(SRCROOT)/Kanna/Modules'
                    }
end

