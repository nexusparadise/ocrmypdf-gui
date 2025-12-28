#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "AppIcon.svg" asset catalog image resource.
static NSString * const ACImageNameAppIconSvg AC_SWIFT_PRIVATE = @"AppIcon.svg";

/// The "Header.svg" asset catalog image resource.
static NSString * const ACImageNameHeaderSvg AC_SWIFT_PRIVATE = @"Header.svg";

/// The "HeaderImage white.svg" asset catalog image resource.
static NSString * const ACImageNameHeaderImageWhiteSvg AC_SWIFT_PRIVATE = @"HeaderImage white.svg";

/// The "HeaderImage white2.svg" asset catalog image resource.
static NSString * const ACImageNameHeaderImageWhite2Svg AC_SWIFT_PRIVATE = @"HeaderImage white2.svg";

/// The "HeaderImage.svg" asset catalog image resource.
static NSString * const ACImageNameHeaderImageSvg AC_SWIFT_PRIVATE = @"HeaderImage.svg";

#undef AC_SWIFT_PRIVATE
