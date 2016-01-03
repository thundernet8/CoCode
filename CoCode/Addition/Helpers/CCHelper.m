
#import "CCHelper.h"
#import "SVProgressHUD.h"
#import "NSDate+Utilities.h"
#import "CCTextAttachment.h"

@implementation CCHelper

+ (NSDate *)localDateWithString:(NSString *)dateString{
    if (dateString == (id)[NSNull null] || dateString.length < 20) {
        return nil;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC+8"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    dateString = [dateString substringWithRange:NSMakeRange(0, 19)];
    return [dateFormatter dateFromString:dateString];
}

+ (NSString *)timeIntervalStringWithDate:(NSDate *)date{
    NSString *timeString;
    NSDate *now = [NSDate date];
    now = [now dateByAddingTimeInterval:-3600*8];
    NSTimeInterval diff = [now timeIntervalSinceDate:date];
    if ((int)diff < 60) {
        timeString = NSLocalizedString(@"Just now", @"Time interval in 60 seconds");
    }else if ((int)diff < 3600){
        timeString = [NSString stringWithFormat:@"%d %@", (int)diff/60, NSLocalizedString(@"minutes ago", @"Time interval in 1 hour")];
    }else if ((int)diff < 3600*24){
        timeString = [NSString stringWithFormat:@"%d %@", (int)diff/3600, NSLocalizedString(@"hours ago", @"Time interval in 1 day")];
    }else if ((int)diff < 3600*24*10){
        timeString = [NSString stringWithFormat:@"%d %@", (int)diff/(3600*24), NSLocalizedString(@"days ago", @"Time interval in 10 days")];
    }else{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC+8"]];
        [dateFormatter setDateFormat:@"yy-MM-dd"];
        NSString *dateStr = [dateFormatter stringFromDate:date];
        NSString *nowStr = [dateFormatter stringFromDate:now];
        if ([[dateStr substringWithRange:NSMakeRange(0, 2)] isEqualToString:[nowStr substringWithRange:NSMakeRange(0, 2)]]) {
            timeString = [dateStr substringWithRange:NSMakeRange(3, 5)];
        }else{
            timeString = dateStr;
        }
    }
    return timeString;
}

+ (NSString *)timeShortIntervalStringWithDate:(NSDate *)date{
    NSString *timeString;
    NSDate *now = [NSDate date];
    now = [now dateByAddingTimeInterval:-3600*8];
    NSTimeInterval diff = [now timeIntervalSinceDate:date];
    if ((int)diff < 60) {
        timeString = NSLocalizedString(@"Just now", @"Time interval in 60 seconds");
    }else if ((int)diff < 3600){
        timeString = [NSString stringWithFormat:@"%d %@", (int)diff/60, NSLocalizedString(@"minutes ago(short)", @"Time interval in 1 hour")];
    }else if ((int)diff < 3600*24){

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC+8"]];
        [dateFormatter setDateFormat:@"hh:mm"];
        timeString = [dateFormatter stringFromDate:date];
        
    }else if ((int)diff < 3600*24*7){

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC+8"]];
        [dateFormatter setDateFormat:@"EEE"];
        timeString = [dateFormatter stringFromDate:date];
        
    }else{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC+8"]];
        [dateFormatter setDateFormat:@"yy/MM/dd"];
        NSString *dateStr = [dateFormatter stringFromDate:date];
        NSString *nowStr = [dateFormatter stringFromDate:now];
        if ([[dateStr substringWithRange:NSMakeRange(0, 2)] isEqualToString:[nowStr substringWithRange:NSMakeRange(0, 2)]]) {
            timeString = [dateStr substringWithRange:NSMakeRange(3, 5)];
        }else{
            timeString = dateStr;
        }
    }
    return timeString;
}

+ (NSString *)timeDetailedIntervalStringWithDate:(NSDate *)date{
    NSString *timeString;
    
    if ([date isToday]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC+8"]];
        [dateFormatter setDateFormat:@"hh:mm"];
        timeString = [dateFormatter stringFromDate:date];
    }else if ([date isYesterday]){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC+8"]];
        [dateFormatter setDateFormat:@"hh:mm"];
        timeString = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Yesterday", nil), [dateFormatter stringFromDate:date]];
    }else if ([date isInWeek]){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC+8"]];
        [dateFormatter setDateFormat:@"EEE hh:mm"];
        timeString = [dateFormatter stringFromDate:date];
    }else if ([date isThisYear]){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC+8"]];
        [dateFormatter setDateFormat:@"MM/dd hh:mm"];
        timeString = [dateFormatter stringFromDate:date];
    }else{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC+8"]];
        [dateFormatter setDateFormat:@"yy/MM/dd hh:mm"];
        timeString = [dateFormatter stringFromDate:date];
    }
    
    return timeString;
}

//SVProgressHud
+ (void)showBlackHudWithImage:(UIImage *)image withText:(NSString *)text{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setForegroundColor:kWhiteColor];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.8]];
    [SVProgressHUD setSuccessImage:image];
    [SVProgressHUD showSuccessWithStatus:text];
}

+ (void)showBlackProgressHudWithText:(NSString *)text{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setForegroundColor:kWhiteColor];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.8]];
    [SVProgressHUD showWithStatus:text];
}

+ (void)dismissAllHud{
    [SVProgressHUD dismiss];
}

//Category info from plist
+ (NSDictionary *)getCategoryInfoFromPlistForID:(NSNumber *)catID{
    NSDictionary *categories = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Categories" ofType:@"plist"]];
    return [categories objectForKey:[NSString stringWithFormat:@"Cat%d", catID.intValue]];
}

//Evaluate text height
+ (CGFloat)getTextHeightWithText:(NSString *)text Font:(UIFont *)font Width:(CGFloat)width {
    
    NSDictionary *attributes = @{NSFontAttributeName:font};
    CGRect expectedLabelRect = [text boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:attributes
                                                  context:nil];
    return ceil(CGRectGetHeight(expectedLabelRect));
    
}

+ (CGFloat)getTextWidthWithText:(NSString *)text Font:(UIFont *)font height:(CGFloat)height{
    NSDictionary *attributes = @{NSFontAttributeName:font};
    CGRect expectedLabelRect = [text boundingRectWithSize:(CGSize){CGFLOAT_MAX, height}
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:attributes
                                                  context:nil];
    return ceil(CGRectGetHeight(expectedLabelRect));
}

+ (UIImage *)getImageFromView:(UIView *)orgView{
    if (orgView) {
        UIGraphicsBeginImageContextWithOptions(orgView.bounds.size, NO, [UIScreen mainScreen].scale);
        [orgView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    } else {
        return nil;
    }
}

+ (NSString *)getAvatarFromTemplate:(NSString *)template withSize:(NSInteger)size{
    if ([[template substringWithRange:NSMakeRange(0, 30)] isEqualToString:@"https://avatars.discourse.org/"]) {
        template = [template stringByReplacingOccurrencesOfString:@"{size}" withString:[NSString stringWithFormat:@"%d", (int)size]];
    }else{
        template = [@"http://cocode.cc" stringByAppendingString:[template stringByReplacingOccurrencesOfString:@"{size}" withString:[NSString stringWithFormat:@"%d", (int)size]]];
    }
    return template;
}


+ (NSArray *)bubbleSortMediaAttachArray:(NSArray *)array{
    NSMutableArray *mutableArray = [array mutableCopy];
    NSInteger count = array.count;
    NSInteger i, j;
    CCTextAttachment *attach;
    CCTextAttachment *attachBeside;
    for (i = 0; i<count; i++) {
        for (j = 1; j<count-i; j++) {
            attach = mutableArray[j-1];
            attachBeside = mutableArray[j];
            if (attach.range.location > attachBeside.range.location) {
                mutableArray[j] = attach;
                mutableArray[j-1] = attachBeside;
            }
        }
    }
    
    return [NSArray arrayWithArray:mutableArray];
}


+ (NSString *)getSystemLanguage{
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

@end
