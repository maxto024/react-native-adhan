// plugin.js
const {
  createRunOncePlugin,
  withPlugins,
  withAndroidManifest,
  withInfoPlist,
} = require('@expo/config-plugins');
const pkg = require('./package.json');

/**
 * The main entry: compose iOS and Android mods.
 */
function withAdhanPlugin(config) {
  return withPlugins(config, [withAdhanIOS, withAdhanAndroid]);
}

/**
 * iOS Info.plist modifications:
 * - Add any required background modes or usage descriptions.
 */
function withAdhanIOS(config) {
  return withInfoPlist(config, ({ modResults }) => {
    // Ensure location and fetch background modes
    modResults.UIBackgroundModes = Array.from(
      new Set([...(modResults.UIBackgroundModes || []), 'location', 'fetch'])
    );
    // Optional: add usage descriptions
    modResults.NSLocationWhenInUseUsageDescription ??=
      'Location is required for accurate prayer times.';
    return { ...config, modResults };
  });
}

/**
 * AndroidManifest.xml modifications:
 * - Add fine location permission.
 */
function withAdhanAndroid(config) {
  return withAndroidManifest(config, ({ modResults }) => {
    const manifest = modResults.manifest || {};
    manifest['uses-permission'] = [
      ...(manifest['uses-permission'] || []),
      { $: { 'android:name': 'android.permission.ACCESS_FINE_LOCATION' } },
    ];
    return { ...config, modResults };
  });
}

module.exports = createRunOncePlugin(withAdhanPlugin, pkg.name, pkg.version);
