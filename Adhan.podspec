require "json"
require "fileutils"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))
version = package['version']

# Pods directory for this library
pods_root = File.join(__dir__, "pods")

# Path to the React Native installation
react_native_path = File.join(__dir__, "node_modules", "react-native")
# Path to the react-native-codegen package
codegen_path = File.join(__dir__, "node_modules", "react-native-codegen")

# React Native script phases
folly_compiler_flags = '-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1 -Wno-comma -Wno-shorten-64-to-32'
folly_version = '2022.05.16.00'

Pod::Spec.new do |s|
  s.name                   = "Adhan"
  s.version                = version
  s.summary                = package["description"]
  s.homepage               = package["homepage"]
  s.license                = package["license"]
  s.author                 = package["author"]
  s.source                 = { :git => package["repository"]["url"], :tag => "v#{s.version}" }
  s.platforms              = { :ios => "13.0" }

  # Use a clean Swift version
  s.swift_version          = "5.0"

  # This is a Swift library, so we need to define a module
  s.module_name = 'Adhan'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'SWIFT_COMPILATION_MODE' => 'wholemodule'
  }

  # Source files for the module
  s.source_files         = "ios/**/*.{h,m,mm}", "ios/adhan-swift/Sources/**/*.swift"
  
  # Exclude test files from the pod
  s.exclude_files        = "ios/adhan-swift/Tests/*"

  # Add support for C++
  s.pod_target_xcconfig    = {
    "HEADER_SEARCH_PATHS" => "\"$(PODS_ROOT)/boost\" \"$(PODS_ROOT)/Headers/Private/React-Core\"",
    "CLANG_CXX_LANGUAGE_STANDARD" => "c++17",
  }

  s.user_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '"$(PODS_TARGET_SRCROOT)/"'
  }
end
