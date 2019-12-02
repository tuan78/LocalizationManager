Pod::Spec.new do |s|
  s.name             = 'LocalizationManager'
  s.version          = '0.1.4'
  s.summary          = 'Lightweight localization handlers and tools for iOS'
  s.description      = <<-DESC
  Lightweight localization handlers and tools for iOS:
  * Check RTL layout direction and update views automatically.
  * Set the app language at runtime without restarting app.
  * Send notification when language and layout LTR direction changes.
  * Check layout direction and update views automatically.
  * Add Plural translation supports.
                       DESC

  s.homepage         = 'https://github.com/tuan78/LocalizationManager'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Tuan Tran' => 'tuantran070892@gmail.com' }
  s.source           = { :git => 'https://github.com/tuan78/LocalizationManager.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.swift_version         = '4.2'
  s.requires_arc          = true
  s.source_files          = 'LocalizationManager/Classes/**/*.{h,m,swift,stringsdict}'
end
