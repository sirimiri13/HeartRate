# Uncomment the next line to define a global platform for your project
# platform :ios, '15.0'

target 'GetColor' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for GetColor

  target 'GetColorTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'GetColorUITests' do
    # Pods for testing
  end
post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end


  	pod 'PhoneNumberKit'
	pod 'TextFieldEffects'
	pod 'FirebaseAuth'	
	pod 'Firebase/Analytics', '8.1.0'
	pod 'JGProgressHUD'

end
