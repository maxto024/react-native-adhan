#ifdef RCT_NEW_ARCH_ENABLED
#import "AdhanSpec.h"

@interface Adhan : NSObject <NativeAdhanSpec>
#else
#import <React/RCTBridgeModule.h>

@interface Adhan : NSObject <RCTBridgeModule>
#endif

@end
