const { createRunOncePlugin, withPlugins, withAndroidManifest, withInfoPlist } = require('@expo/config-plugins');
const pkg = require('./package.json');

function withAdhanPlugin(config) {
  // This is a placeholder for any future native modifications.
  return withPlugins(config, [
    (cfg) => withAndroidManifest(cfg, (c) => c),
    (cfg) => withInfoPlist(cfg, (c) => c),
  ]);
}

module.exports = createRunOncePlugin(
  withAdhanPlugin,
  pkg.name,
  pkg.version
);
