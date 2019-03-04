Pod::Spec.new do |spec|
  spec.name                      = "TOMLDeserializer"
  spec.version                   = "0.1.0"
  spec.summary                   = "RFC  compliant date/time data types."
  spec.homepage                  = "https://github.com/dduan/TOMLDeserializer"
  spec.license                   = { :type => "MIT", :file => "LICENSE.md" }
  spec.author                    = { "Daniel Duan" => "daniel@duan.ca" }
  spec.social_media_url          = "https://twitter.com/daniel_duan"
  spec.ios.deployment_target     = "8.0"
  spec.osx.deployment_target     = "10.10"
  spec.tvos.deployment_target    = "9.0"
  spec.watchos.deployment_target = "2.0"
  spec.swift_version             = '4.2.1'
  spec.source                    = { :git => "https://github.com/dduan/TOMLDeserializer.git", :tag => "#{spec.version}" }
  spec.source_files              = "Sources/**/*.swift"
  spec.requires_arc              = true
  spec.module_name               = "TOMLDeserializer"
  spec.dependency  "NetTime", '~> 0.1.0'
end
