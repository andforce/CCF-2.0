//
//  https://github.com/sebyddd/SDVersion
//
//  Created by 迪远 王 on 16/10/2.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "DeviceName.h"

#import <sys/utsname.h>

#import "Forum.pch"

#import <UIKit/UIKit.h>

@implementation DeviceName

+ (NSString *)platform{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    return platform;
}

+ (NSString *)deviceName{
    return [self platformString:[self platform]];
}

+ (NSString *)deviceNameDetail{
    return [self platformDetailString:[self platform]];
}

+ (NSString *)platformDetailString:(NSString *)platform {
    
    // iPhone
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3Gs";
    
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4s";
    
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhoneSE";
    
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone9,4"]) return @"iPhone 7 Plus";
    
    if ([platform isEqualToString:@"iPhone10,1"]) return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,2"]) return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,3"]) return @"iPhone X";
    if ([platform isEqualToString:@"iPhone10,6"]) return @"iPhone X";
    
    if ([platform isEqualToString:@"i386"]) return @"Simulator";
    if ([platform isEqualToString:@"x86_64"]) return @"Simulator";
    
    // iPad
    if ([platform isEqualToString:@"iPad1,1"]) return @"iPad 1";
    
    if ([platform isEqualToString:@"iPad2,1"]) return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,2"]) return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"]) return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,4"]) return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,5"]) return @"iPad Mini";
    if ([platform isEqualToString:@"iPad2,6"]) return @"iPad Mini";
    if ([platform isEqualToString:@"iPad2,7"]) return @"iPad Mini";
    
    if ([platform isEqualToString:@"iPad3,1"]) return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,2"]) return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,3"]) return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,4"]) return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,5"]) return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"]) return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad4,1"]) return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,2"]) return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,3"]) return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,4"]) return @"iPad Mini 2";
    if ([platform isEqualToString:@"iPad4,5"]) return @"iPad Mini 2";
    if ([platform isEqualToString:@"iPad4,6"]) return @"iPad Mini 2";
    
    if ([platform isEqualToString:@"iPad4,7"]) return @"iPad Mini 3";
    if ([platform isEqualToString:@"iPad4,8"]) return @"iPad Mini 3";
    if ([platform isEqualToString:@"iPad4,9"]) return @"iPad Mini 3";
    
    if ([platform isEqualToString:@"iPad5,1"]) return @"iPad Mini 4";
    if ([platform isEqualToString:@"iPad5,2"]) return @"iPad Mini 4";
    
    if ([platform isEqualToString:@"iPad5,3"]) return @"iPad Air 2";
    if ([platform isEqualToString:@"iPad5,4"]) return @"iPad Air 2";
    
    if ([platform isEqualToString:@"iPad6,3"]) return @"iPad Pro 9.7 Inch";
    if ([platform isEqualToString:@"iPad6,4"]) return @"iPad Pro 9.7 Inch";
    
    if ([platform isEqualToString:@"iPad6,7"]) return @"iPad Pro 12.9 Inch";
    if ([platform isEqualToString:@"iPad6,8"]) return @"iPad Pro 12.9 Inch";
    
    
    // Apple TV
    if ([platform isEqualToString:@"AppleTV2,1"]) return @"Apple TV 2G";
    if ([platform isEqualToString:@"AppleTV3,1"]) return @"Apple TV 3";
    if ([platform isEqualToString:@"AppleTV3,2"]) return @"Apple TV 3 (2013)";
    if ([platform isEqualToString:@"AppleTV5,3"]) return @"Apple TV 4 (2015)";
    if ([platform isEqualToString:@"Watch1,1"]) return @"Apple Watch (38mm)";
    if ([platform isEqualToString:@"Watch1,2"]) return @"Apple Watch (42mm)";
    
    // iPod
    if ([platform isEqualToString:@"iPod1,1"]) return @"iPod touch 1G";
    if ([platform isEqualToString:@"iPod2,1"]) return @"iPod touch 2G";
    if ([platform isEqualToString:@"iPod3,1"]) return @"iPod touch 3";
    if ([platform isEqualToString:@"iPod4,1"]) return @"iPod touch 4";
    if ([platform isEqualToString:@"iPod5,1"]) return @"iPod touch 5";
    if ([platform isEqualToString:@"iPod7,1"]) return @"iPod touch 6";
    
    return platform;
}


+ (NSString *)platformString:(NSString *)platform {
    
    // iPhone
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3G[S]";
    
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4 (GSM)";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4 (GSM/2012)";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4 (CDMA)";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4[S]";
    
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (Global)";
    
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c (Global)";
    
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s (Global)";
    
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6+";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s+";
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhoneSE";
    if ([platform isEqualToString:@"i386"]) return @"Simulator";
    if ([platform isEqualToString:@"x86_64"]) return @"Simulator";
    
    // iPad
    if ([platform isEqualToString:@"iPad1,1"]) return @"iPad 1";
    
    if ([platform isEqualToString:@"iPad2,1"]) return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"]) return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"]) return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"]) return @"iPad 2 (Mid 2012)";
    
    if ([platform isEqualToString:@"iPad2,5"]) return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"]) return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"]) return @"iPad Mini (Global)";
    
    if ([platform isEqualToString:@"iPad3,1"]) return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"]) return @"iPad 3 (CDMA)";
    if ([platform isEqualToString:@"iPad3,3"]) return @"iPad 3 (GSM)";
    
    if ([platform isEqualToString:@"iPad3,4"]) return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"]) return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"]) return @"iPad 4 (Global)";
    
    if ([platform isEqualToString:@"iPad4,1"]) return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"]) return @"iPad Air (Cellular)";
    if ([platform isEqualToString:@"iPad4,3"]) return @"iPad Air (China)";
    
    if ([platform isEqualToString:@"iPad4,4"]) return @"iPad Mini 2 (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"]) return @"iPad Mini 2 (Cellular)";
    if ([platform isEqualToString:@"iPad4,6"]) return @"iPad Mini 2 (China)";
    
    if ([platform isEqualToString:@"iPad4,7"]) return @"iPad Mini 3 (WiFi)";
    if ([platform isEqualToString:@"iPad4,8"]) return @"iPad Mini 3 (Cellular)";
    if ([platform isEqualToString:@"iPad4,9"]) return @"iPad Mini 3 (China)";
    
    if ([platform isEqualToString:@"iPad5,1"]) return @"iPad Mini 4 (WiFi)";
    if ([platform isEqualToString:@"iPad5,2"]) return @"iPad Mini 4 (Cellular)";
    
    if ([platform isEqualToString:@"iPad5,3"]) return @"iPad Air 2 (WiFi)";
    if ([platform isEqualToString:@"iPad5,4"]) return @"iPad Air 2 (Cellular)";
    
    if ([platform isEqualToString:@"iPad6,3"]) return @"iPad Pro 9.7 Inch";
    if ([platform isEqualToString:@"iPad6,4"]) return @"iPad Pro 9.7 Inch";
    
    if ([platform isEqualToString:@"iPad6,7"]) return @"iPad Pro (WiFi)";
    if ([platform isEqualToString:@"iPad6,8"]) return @"iPad Pro (Cellular)";
    
    
    // Apple TV
    if ([platform isEqualToString:@"AppleTV2,1"]) return @"Apple TV 2G";
    if ([platform isEqualToString:@"AppleTV3,1"]) return @"Apple TV 3";
    if ([platform isEqualToString:@"AppleTV3,2"]) return @"Apple TV 3 (2013)";
    if ([platform isEqualToString:@"AppleTV5,3"]) return @"Apple TV 4 (2015)";
    if ([platform isEqualToString:@"Watch1,1"]) return @"Apple Watch (38mm)";
    if ([platform isEqualToString:@"Watch1,2"]) return @"Apple Watch (42mm)";
    
    // iPod
    if ([platform isEqualToString:@"iPod1,1"]) return @"iPod touch 1G";
    if ([platform isEqualToString:@"iPod2,1"]) return @"iPod touch 2G";
    if ([platform isEqualToString:@"iPod3,1"]) return @"iPod touch 3";
    if ([platform isEqualToString:@"iPod4,1"]) return @"iPod touch 4";
    if ([platform isEqualToString:@"iPod5,1"]) return @"iPod touch 5";
    if ([platform isEqualToString:@"iPod7,1"]) return @"iPod touch 6";

    if (SCREEN_WIDTH == 828 && SCREEN_HEIGHT == 1792){
        return @"iPhone XR";
    }

    if (SCREEN_WIDTH == 1125 && SCREEN_HEIGHT == 2436){
        return @"iPhone XS";
    }

    if (SCREEN_WIDTH == 1242 && SCREEN_HEIGHT == 2688){
        return @"iPhone XS Max";
    }

    return platform;
}


@end
