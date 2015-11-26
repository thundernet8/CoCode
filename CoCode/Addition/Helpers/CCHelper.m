
#import "CCHelper.h"
#import "SVProgressHUD.h"
#import "NSDate+Utilities.h"

@implementation CCHelper

+ (NSDate *)localDateWithString:(NSString *)dateString{
    if (dateString == [NSNull null] || dateString.length < 20) {
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

//Category info from plist
+ (NSDictionary *)getCategoryInfoFromPlistForID:(NSNumber *)catID{
    NSDictionary *categories = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Categories" ofType:@"plist"]];
    return [categories objectForKey:[NSString stringWithFormat:@"Cat%d", catID.intValue]];
}

//Evaluate title height for topic cell
+ (CGFloat)getTextHeightWithText:(NSString *)text Font:(UIFont *)font Width:(CGFloat)width {
    
    NSDictionary *attributes = @{NSFontAttributeName:font};
    CGRect expectedLabelRect = [text boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:attributes
                                                  context:nil];
    return CGRectGetHeight(expectedLabelRect);
    
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




























+ (NSArray *)localDateStringWithUTCString:(NSString *)dateString {
    
    NSDateFormatter *utcDateFormatter = [[NSDateFormatter alloc] init];
    [utcDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [utcDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *utcDate = [utcDateFormatter dateFromString:dateString];
    
    NSDateFormatter *localDateFormatter = [[NSDateFormatter alloc] init];
    [localDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [localDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *localTimeString = [localDateFormatter stringFromDate:utcDate];
    NSArray *localArray = [localTimeString componentsSeparatedByString:@" "];
    return localArray;
    
}

+ (NSArray *)localDateStringWithUTCString:(NSString *)dateString Separation:(NSString *)separation {
    
    NSDateFormatter *utcDateFormatter = [[NSDateFormatter alloc] init];
    [utcDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [utcDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *utcDate = [utcDateFormatter dateFromString:dateString];
    
    NSDateFormatter *localDateFormatter = [[NSDateFormatter alloc] init];
    [localDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *formateString = [NSString stringWithFormat:@"yyyy%@MM%@dd HH:mm", separation, separation];
    [localDateFormatter setDateFormat:formateString];
    NSString *localTimeString = [localDateFormatter stringFromDate:utcDate];
    NSArray *localArray = [localTimeString componentsSeparatedByString:@" "];
    return localArray;
    
}

//+ (NSDate *)localDateWithUTCString:(NSString *)dateString {
//    NSDateFormatter *utcDateFormatter = [[NSDateFormatter alloc] init];
//    [utcDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
//    [utcDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSDate *utcDate = [utcDateFormatter dateFromString:dateString];
//
//    NSDateFormatter *localDateFormatter = [[NSDateFormatter alloc] init];
//    [localDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
//    [localDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
//
//    NSDate *localDate = [utcDate da]
//}

+ (NSTimeInterval)timeIntervalWithUTCString:(NSString *)dateString {
    
    NSDateFormatter *utcDateFormatter = [[NSDateFormatter alloc] init];
    [utcDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [utcDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *utcDate = [utcDateFormatter dateFromString:dateString];
    
    NSTimeInterval interval = [utcDate timeIntervalSinceNow];
    return interval;
}

+ (NSString *)timeRemainDescriptionWithTimeInterval:(NSTimeInterval)interval {
    
//    NSString *minuteStr = localize(@"minute");
//    NSString *hourStr = localize(@"hour");
//    NSString *dayStr = localize(@"day");
//    NSString *weekStr = localize(@"week");
//    
//    if (interval < 0) {
//        interval = -interval;
//    }
//    
//    CGFloat minute = interval / 60.0f;
//    if (minute < 60.0f) {
//        if (minute < 2.0f) {
//            return localize(@"just now");
//        }
//        return [NSString stringWithFormat:@"%.f%@%@", minute, minuteStr, @"前"];
//    } else {
//        CGFloat hour = minute / 60.0f;
//        if (hour < 24.0f) {
//            return [NSString stringWithFormat:@"%.f%@%@", hour, hourStr, @"前"];
////            return [NSString stringWithFormat:@"%.f%@%.f%@", hour, hourStr, minute-60*(int)hour, minuteStr];
//        } else {
//            CGFloat day = hour / 24.0f;
//            if (day < 7.0f) {
////                return [NSString stringWithFormat:@"%.f%@%.f%@", day, dayStr, hour-24*(int)day , hourStr];
//                return [NSString stringWithFormat:@"%.f%@%@", day, dayStr, @"前"];
//            } else {
//                CGFloat week = day / 7.0f;
//                return [NSString stringWithFormat:@"%.f%@", week, weekStr];
//            }
//        }
//    }
    return nil;
    
}

+ (NSString *)timeRemainDescriptionWithUTCString:(NSString *)dateString {

//    NSString *minuteStr = @" minutes";
//    NSString *hourStr = @" hours";
//    NSString *dayStr = @" days";
//    NSString *minuteStr = @"m";
//    NSString *hourStr = @"h";
//    NSString *dayStr = @"d";
    NSString *minuteStr = @"分钟";
    NSString *hourStr = @"小时";
    NSString *dayStr = @"天";
//    NSString *weekStr = localize(@"week");
    
    NSTimeInterval interval = [self timeIntervalWithUTCString:dateString];

    
    NSString *before = @"";
    
    if (interval < 0) {
        interval = -interval;
        before = @"前";
    }
    
    CGFloat minute = interval / 60.0f;
    if (minute < 60.0f) {
        if (minute < 1.0f) {
            return @"刚刚";
        }
        return [NSString stringWithFormat:@"%.f%@%@", minute, minuteStr, before];
    } else {
        CGFloat hour = minute / 60.0f;
        if (hour < 24.0f) {
            return [NSString stringWithFormat:@"%.f%@%@", hour, hourStr, before];
        } else {
            CGFloat day = hour / 24.0f;
            if (day < 7.0f) {
                return [NSString stringWithFormat:@"%.f%@%@", day, dayStr, before];
            } else {
                NSArray *dateArray = [self localDateStringWithUTCString:dateString];
                if (dateArray.count == 2) {
                    return dateArray[0];
                } else {
                    return dateString;
                }
            }
        }
    }
    return nil;
    
}

+ (NSString *)timeRemainDescriptionWithDateSP:(NSNumber *)dateSP {
    
    NSDate *timesp = [NSDate dateWithTimeIntervalSince1970:[dateSP floatValue]];
    NSDateFormatter *utcDateFormatter = [[NSDateFormatter alloc] init];
    [utcDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [utcDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [utcDateFormatter stringFromDate:timesp];

    return [CCHelper timeRemainDescriptionWithUTCString:dateString];
}

+ (CGFloat)getTextWidthWithText:(NSString *)text Font:(UIFont *)font {
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: font,
                                 };
    CGRect expectedLabelRect = [text boundingRectWithSize:(CGSize){CGFLOAT_MAX, CGFLOAT_MAX}
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:attributes
                                                  context:nil];
    return CGRectGetWidth(expectedLabelRect);
    
}




+ (NSString *)encodeUrlString:(NSString *)urlString {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)urlString,
                                                               NULL,
                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                               kCFStringEncodingUTF8));
}



+ (UIImage *)getImageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)getImageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


+ (void)showNetwortStatus {
    
    if (![AFNetworkReachabilityManager sharedManager].isReachable) {
        UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"网络好像有点问题，请检查网络后再尝试" message:@""];
        [alertView bk_setCancelButtonWithTitle:@"确定" handler:^{
            ;
        }];
        [alertView show];
    }
    
}


/**
 *  Setting
 */

+ (UIImage *)getUserAvatarDefaultFromGender:(NSInteger)gender {
    
    if (gender == 2) {
        return [UIImage imageNamed:@"Avatar_User_Female"];
    } else {
        return [UIImage imageNamed:@"Avatar_User_Male"];
    }
}


@end
