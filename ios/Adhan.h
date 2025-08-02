#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

#ifdef RCT_NEW_ARCH_ENABLED
#import <AdhanSpec/AdhanSpec.h>
@interface Adhan : RCTEventEmitter <NativeAdhanSpec>
#else
@interface Adhan : RCTEventEmitter <RCTBridgeModule>
#endif

@end