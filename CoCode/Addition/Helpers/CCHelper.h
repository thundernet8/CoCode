
#import <Foundation/Foundation.h>

@interface CCHelper : NSObject

/**
 *  Time & date
 */

+ (NSDate *)localDateWithString:(NSString *)dateString;
+ (NSString *)timeIntervalStringWithDate:(NSDate *)date;

//SVProgressHud
+ (void)showBlackHudWithImage:(UIImage *)image withText:(NSString *)text;

//Category info from plist
+ (NSDictionary *)getCategoryInfoFromPlistForID:(NSNumber *)catID;

//Get view image
+ (UIImage *)getImageFromView:(UIView *)view;

//Get avatar from template
+ (NSString *)getAvatarFromTemplate:(NSString *)template withSize:(NSInteger)size;





+ (NSArray *)localDateStringWithUTCString:(NSString *)dateString;

+ (NSArray *)localDateStringWithUTCString:(NSString *)dateString Separation:(NSString *)separation;

+ (NSTimeInterval)timeIntervalWithUTCString:(NSString *)dateString;

+ (NSString *)timeRemainDescriptionWithTimeInterval:(NSTimeInterval)interval;

+ (NSString *)timeRemainDescriptionWithUTCString:(NSString *)dateString;

+ (NSString *)timeRemainDescriptionWithDateSP:(NSNumber *)dateSP;

+ (CGFloat)getTextWidthWithText:(NSString *)text Font:(UIFont *)font;

+ (CGFloat)getTextHeightWithText:(NSString *)text Font:(UIFont *)font Width:(CGFloat)width;


/**
 *  Other
 */

+ (NSString *)encodeUrlString:(NSString *)urlString;



+ (UIImage *)getImageWithColor:(UIColor *)color;

+ (UIImage *)getImageWithColor:(UIColor *)color size:(CGSize)size;


/**
 *  Setting
 */

+ (UIImage *)getUserAvatarDefaultFromGender:(NSInteger)gender;


@end



