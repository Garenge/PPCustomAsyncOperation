#
# Be sure to run `pod lib lint PPCustomAsyncOperation.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PPCustomAsyncOperation'
  s.version          = '0.1.3'
  s.summary          = 'Easy way to run async tasks in queue with PPCustomAsyncOperation.'

  s.description      = <<-DESC
Add timeout block.
                       DESC

  s.homepage         = 'https://github.com/Garenge/PPCustomAsyncOperation'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'pengpeng' => 'garenge@outlook.com' }
  s.source           = { :git => 'https://github.com/Garenge/PPCustomAsyncOperation.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.pod_target_xcconfig = {
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
  }
  
  s.user_target_xcconfig = {
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
  }

  s.source_files = 'PPCustomAsyncOperation/Classes/**/*'

  s.public_header_files = 'PPCustomAsyncOperation/Classes/**/*.h'
end
