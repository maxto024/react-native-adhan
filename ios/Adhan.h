#import <React/RCTBridgeModule.h>

#ifdef RCT_NEW_ARCH_ENABLED
#import <AdhanSpec/AdhanSpec.h>
@interface Adhan : NSObject <NativeAdhanSpec>
#else
@interface Adhan : NSObject <RCTBridgeModule>
#endif

@end