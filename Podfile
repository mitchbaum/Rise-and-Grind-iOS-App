# Uncomment the next line to define a global platform for your project
 platform :ios, '13.0'

target 'RiseAndGrind' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for RiseAndGrind
  pod 'Firebase/Auth'
  pod 'Firebase/Core'
  pod 'Firebase/Firestore'
  pod 'FirebaseFirestoreSwift'
  pod 'JGProgressHUD'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'LBTATools'
  pod 'IQKeyboardManagerSwift'
  pod 'Firebase/Analytics'

  target 'RiseAndGrindTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'RiseAndGrindUITests' do
    # Pods for testing
  end

end
post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'BoringSSL-GRPC'
      target.source_build_phase.files.each do |file|
        if file.settings && file.settings['COMPILER_FLAGS']
          flags = file.settings['COMPILER_FLAGS'].split
          flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
          file.settings['COMPILER_FLAGS'] = flags.join(' ')
        end
      end
    end
	target.build_configurations.each do |config|
      config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "11.0"
    end
  end
end