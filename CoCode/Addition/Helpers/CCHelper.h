
#import <Foundation/Foundation.h>

@interface CCHelper : NSObject

/**
 *  Time & date
 */

+ (NSDate *)localDateWithString:(NSString *)dateString;
+ (NSString *)timeIntervalStringWithDate:(NSDate *)date;
+ (NSString *)timeShortIntervalStringWithDate:(NSDate *)date;
+ (NSString *)timeDetailedIntervalStringWithDate:(NSDate *)date;

//SVProgressHud
+ (void)showBlackHudWithImage:(UIImage *)image withText:(NSString *)text;

+ (void)showBlackProgressHudWithText:(NSString *)text;

+ (void)dismissAllHud;

//Category info from plist
+ (NSDictionary *)getCategoryInfoFromPlistForID:(NSNumber *)catID;

//Get view image
+ (UIImage *)getImageFromView:(UIView *)view;

//Get avatar from template
+ (NSString *)getAvatarFromTemplate:(NSString *)template withSize:(NSInteger)size;

//Get text height
+ (CGFloat)getTextHeightWithText:(NSString *)text Font:(UIFont *)font Width:(CGFloat)width;

//Get  single line text width
+ (CGFloat)getTextWidthWithText:(NSString *)text Font:(UIFont *)font height:(CGFloat)height;

//Bubble Sort CCTextAttachment
+ (NSArray *)bubbleSortMediaAttachArray:(NSArray *)array;


@end



