Pod::Spec.new do |s|
  s.name             = "Kanna"
  s.version          = "5.2.8"
  s.summary          = "Kanna is an XML/HTML parser for iOS/macOS/watchOS/tvOS and Linux."
  s.homepage         = "https://github.com/tid-kijyun/Kanna"
  s.license          = 'MIT'
  s.author           = { "Atsushi Kiwaki" => "tid.develop@gmail.com" }
  s.source           = { :git => "https://github.com/tid-kijyun/Kanna.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/_tid_'
  s.swift_versions   = '5'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = "9.0"
  s.watchos.deployment_target = "2.0"
  s.requires_arc = true
  s.source_files  = ['Sources/**/*.swift', 'Sources/**/*.h']
  s.resource_bundles = {'kanna_privacy' => ['Kanna/PrivacyInfo.xcprivacy']}
  s.xcconfig      = {
                      'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2',
                      'OTHER_LDFLAGS' => '-lxml2'
                    }
end

