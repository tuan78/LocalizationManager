Pod::Spec.new do |s|
  s.name             = 'LocalizationManager'
  s.version          = '0.1.0'
  s.summary          = 'Localization manager used to handle app language changes without restarting app, check LTR and more.'
  s.description      = <<-DESC
  Localization manager supports:
  * Set the global language at runtime without restarting app.
  * Send notification when language changes.
  * Check LTR and update views automatically.
                       DESC

  s.homepage         = 'https://github.com/tuan78/LocalizationManager'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Tuan Tran' => 'tuantran070892@gmail.com' }
  s.source           = { :git => 'https://github.com/tuan78/LocalizationManager.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.swift_version         = '4.2'
  s.requires_arc          = true
  s.source_files          = 'LocalizationManager/Classes/**/*'
end
