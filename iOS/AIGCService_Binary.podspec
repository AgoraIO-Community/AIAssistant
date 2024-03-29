Pod::Spec.new do |s|
  s.name             = 'AgoraAIGCService'
  s.version          = '1.1.0'
  s.summary          = 'AIGCService'
  
  s.description      = <<-DESC
  TODO: Add long description of the pod here.
  DESC
  
  s.homepage         = 'https://github.com'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ZYP' => 'xxx@agora.io' }
  s.source           = { :git => 'https://github.com', :tag => s.version.to_s }
  
  s.ios.deployment_target = '11.0'
  s.vendored_frameworks = ["*.xcframework", "*.framework"]
  s.platform = :ios
  s.dependency 'SocketRocket', '0.7.0'
  s.dependency 'MicrosoftCognitiveServicesSpeech-iOS', '~> 1.25'
end
