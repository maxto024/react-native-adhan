/**
 * Expo config plugin for react-native-adhan
 * Handles native code modifications for Expo development builds
 */

import { ConfigPlugin, withDangerousMod, withPlugins } from '@expo/config-plugins';
import { ExpoConfig } from '@expo/config-types';
import * as fs from 'fs';
import * as path from 'path';

interface AdhanPluginOptions {
  /** Enable C++ optimizations */
  enableCppOptimizations?: boolean;
  /** Custom calculation methods to include */
  customMethods?: string[];
}

const withAdhanAndroid: ConfigPlugin<AdhanPluginOptions> = (config, options = {}) => {
  return withDangerousMod(config, [
    'android',
    async (config) => {
      const projectRoot = config.modRequest.projectRoot;
      const androidProjectPath = path.join(projectRoot, 'android');

      // Ensure CMakeLists.txt exists and is properly configured
      const cmakeListsPath = path.join(androidProjectPath, 'CMakeLists.txt');
      const buildGradlePath = path.join(androidProjectPath, 'app', 'build.gradle');

      // Add CMake configuration to build.gradle if not present
      if (fs.existsSync(buildGradlePath)) {
        let buildGradleContent = fs.readFileSync(buildGradlePath, 'utf8');
        
        if (!buildGradleContent.includes('cmake {')) {
          const cmakeConfig = `
android {
    ...
    externalNativeBuild {
        cmake {
            path "../CMakeLists.txt"
            version "3.18.1"
        }
    }
    defaultConfig {
        ...
        externalNativeBuild {
            cmake {
                cppFlags "-O2 -frtti -fexceptions"
                abiFilters "arm64-v8a", "armeabi-v7a", "x86", "x86_64"
                arguments "-DANDROID_STL=c++_shared"
            }
        }
    }
}`;
          
          // Insert CMake configuration
          const androidBlockMatch = buildGradleContent.match(/(android\s*{[^}]*})/s);
          if (androidBlockMatch) {
            buildGradleContent = buildGradleContent.replace(
              androidBlockMatch[0],
              cmakeConfig
            );
            fs.writeFileSync(buildGradlePath, buildGradleContent);
          }
        }
      }

      // Create CMakeLists.txt if it doesn't exist
      if (!fs.existsSync(cmakeListsPath)) {
        const cmakeContent = `cmake_minimum_required(VERSION 3.18.1)
project(ReactNativeAdhan)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find React Native
find_package(ReactAndroid REQUIRED CONFIG)

# Add C++ source files
file(GLOB CPP_SOURCES 
    "../node_modules/react-native-adhan/cpp/*.cpp"
    "../node_modules/react-native-adhan/cpp/third_party/adhan-cpp/src/*.cpp"
)

# Create adhan-cpp static library
add_library(adhan-cpp STATIC \${CPP_SOURCES})

target_include_directories(adhan-cpp PUBLIC
    ../node_modules/react-native-adhan/cpp/third_party/adhan-cpp/include
    ../node_modules/react-native-adhan/cpp
)

# Create main native library
add_library(adhan-native SHARED
    ../node_modules/react-native-adhan/cpp/PrayerTimes.cpp
    ../node_modules/react-native-adhan/cpp/JniBridge.cpp
)

target_link_libraries(adhan-native
    ReactAndroid::reactnativejni
    adhan-cpp
    android
    log
)

target_include_directories(adhan-native PRIVATE
    ../node_modules/react-native-adhan/cpp/third_party/adhan-cpp/include
    ../node_modules/react-native-adhan/cpp
)
`;
        fs.writeFileSync(cmakeListsPath, cmakeContent);
      }

      return config;
    },
  ]);
};

const withAdhanIOS: ConfigPlugin<AdhanPluginOptions> = (config, options = {}) => {
  return withDangerousMod(config, [
    'ios',
    async (config) => {
      const projectRoot = config.modRequest.projectRoot;
      const iosProjectPath = path.join(projectRoot, 'ios');
      
      // Find the main iOS project file
      const projectFiles = fs.readdirSync(iosProjectPath).filter(f => f.endsWith('.xcodeproj'));
      if (projectFiles.length === 0) return config;

      const projectName = projectFiles[0].replace('.xcodeproj', '');
      const podfilePath = path.join(iosProjectPath, 'Podfile');

      // Add pod configuration to Podfile if not present
      if (fs.existsSync(podfilePath)) {
        let podfileContent = fs.readFileSync(podfilePath, 'utf8');
        
        if (!podfileContent.includes('react-native-adhan')) {
          const podConfig = `
  # react-native-adhan C++ configuration
  pod 'react-native-adhan', :path => '../node_modules/react-native-adhan'
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      if target.name == 'react-native-adhan'
        target.build_configurations.each do |config|
          config.build_settings['HEADER_SEARCH_PATHS'] ||= []
          config.build_settings['HEADER_SEARCH_PATHS'] << '$(PODS_TARGET_SRCROOT)/cpp/third_party/adhan-cpp/include'
          config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= []
          config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'ADHAN_EXPO_BUILD=1'
          config.build_settings['CLANG_CXX_LANGUAGE_STANDARD'] = 'c++17'
          config.build_settings['CLANG_CXX_LIBRARY'] = 'libc++'
        end
      end
    end
  end`;
          
          // Insert pod configuration before the end of the target block
          const targetMatch = podfileContent.match(/(target\s+['"][^'"]+['"]\s+do[^]+?)(end)/);
          if (targetMatch) {
            podfileContent = podfileContent.replace(
              targetMatch[0],
              targetMatch[1] + podConfig + '\n' + targetMatch[2]
            );
            fs.writeFileSync(podfilePath, podfileContent);
          }
        }
      }

      return config;
    },
  ]);
};

const withAdhanMetro: ConfigPlugin<AdhanPluginOptions> = (config, options = {}) => {
  return withDangerousMod(config, [
    'metro',
    async (config) => {
      const projectRoot = config.modRequest.projectRoot;
      const metroConfigPath = path.join(projectRoot, 'metro.config.js');

      // Create or update metro.config.js for C++ file handling
      const metroConfig = `const { getDefaultConfig } = require('expo/metro-config');

const config = getDefaultConfig(__dirname);

// Add support for C++ files and headers
config.resolver.assetExts.push('cpp', 'hpp', 'h', 'c', 'cc', 'cxx');
config.resolver.sourceExts.push('cpp', 'hpp', 'h', 'c', 'cc', 'cxx');

// Ensure react-native-adhan C++ files are included
config.watchFolders = [
  ...config.watchFolders,
  require('path').resolve(__dirname, 'node_modules/react-native-adhan/cpp')
];

module.exports = config;
`;

      if (!fs.existsSync(metroConfigPath)) {
        fs.writeFileSync(metroConfigPath, metroConfig);
      } else {
        let existingConfig = fs.readFileSync(metroConfigPath, 'utf8');
        if (!existingConfig.includes('react-native-adhan')) {
          // Add our configuration to existing metro config
          const lines = existingConfig.split('\n');
          const moduleExportIndex = lines.findIndex(line => line.includes('module.exports'));
          
          if (moduleExportIndex > 0) {
            lines.splice(moduleExportIndex, 0, 
              '',
              '// react-native-adhan C++ support',
              'config.resolver.assetExts.push("cpp", "hpp", "h", "c", "cc", "cxx");',
              'config.resolver.sourceExts.push("cpp", "hpp", "h", "c", "cc", "cxx");',
              'config.watchFolders = [...config.watchFolders, require("path").resolve(__dirname, "node_modules/react-native-adhan/cpp")];',
              ''
            );
            fs.writeFileSync(metroConfigPath, lines.join('\n'));
          }
        }
      }

      return config;
    },
  ]);
};

/**
 * Main Expo config plugin for react-native-adhan
 * Configures native builds for Expo development builds
 */
const withAdhan: ConfigPlugin<AdhanPluginOptions> = (config, options = {}) => {
  // Apply all platform-specific configurations
  config = withPlugins(config, [
    [withAdhanAndroid, options],
    [withAdhanIOS, options], 
    [withAdhanMetro, options]
  ]);

  // Add plugin configuration to expo config
  if (!config.plugins) config.plugins = [];
  
  // Ensure we have the required dependencies
  if (!config.expo?.developmentClient) {
    config.expo = { ...config.expo, developmentClient: {} };
  }

  return config;
};

export default withAdhan;