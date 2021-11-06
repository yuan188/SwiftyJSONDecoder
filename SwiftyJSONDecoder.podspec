#
# Be sure to run `pod lib lint SwiftyJSONDecoder.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftyJSONDecoder'
  s.version          = '1.1.0'
  s.summary          = 'SwiftyJSON decoder for Codable.'

  s.description      = <<-DESC
  为Codable 使用SwiftyJSON解析数据，以提供默认类型转换及默认值，以便更简单使用Codable
                       DESC

  s.homepage         = 'https://github.com/yuan188/SwiftyJSONDecoder'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yuan188' => 'yuan188' }
  s.source           = { :git => 'https://github.com/yuan188/SwiftyJSONDecoder.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '3.0'

  s.source_files = 'SwiftyJSONDecoder/Classes/**/*'

  s.dependency 'SwiftyJSON', '~> 5.0.0'
  s.swift_version = '5.0'
end
