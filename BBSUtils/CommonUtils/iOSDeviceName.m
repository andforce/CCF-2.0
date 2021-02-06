//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "iOSDeviceName.h"

#import <sys/utsname.h>

@implementation iOSDeviceName

+ (NSString *)platform{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    return platform;
}

+ (NSString *)deviceName{
    return [self platformDetailString:[self platform]];
}

+ (NSString *)platformDetailString:(NSString *)platform {

    //参考型号
    //https://www.theiphonewiki.com/wiki/Models

    // iPhone
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3Gs";
    
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4s";
    if ([platform isEqualToString:@"iPhone4,2"]) return @"iPhone 4s";
    if ([platform isEqualToString:@"iPhone4,3"]) return @"iPhone 4s";
    
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
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE 1";
    
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,3"]) return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone9,4"]) return @"iPhone 7 Plus";
    
    if ([platform isEqualToString:@"iPhone10,1"]) return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,2"]) return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,3"]) return @"iPhone X";
    if ([platform isEqualToString:@"iPhone10,6"]) return @"iPhone X";

    if ([platform isEqualToString:@"iPhone11,2"]) return @"iPhone XS";
    if ([platform isEqualToString:@"iPhone11,4"]) return @"iPhone XS Max";
    if ([platform isEqualToString:@"iPhone11,6"]) return @"iPhone XS Max";
    if ([platform isEqualToString:@"iPhone11,8"]) return @"iPhone XR";

    if ([platform isEqualToString:@"iPhone12,1"]) return @"iPhone 11";
    if ([platform isEqualToString:@"iPhone12,3"]) return @"iPhone 11 Pro";
    if ([platform isEqualToString:@"iPhone12,5"]) return @"iPhone 11 Pro Max";
    
    if ([platform isEqualToString:@"iPhone12,8"]) return @"iPhone SE 2";
    
    if ([platform isEqualToString:@"iPhone13,1"]) return @"iPhone 12 mini";
    if ([platform isEqualToString:@"iPhone13,2"]) return @"iPhone 12";
    if ([platform isEqualToString:@"iPhone13,3"]) return @"iPhone 12 Pro";
    if ([platform isEqualToString:@"iPhone13,4"]) return @"iPhone 12 Pro Max";
    
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

    if ([platform isEqualToString:@"iPad6,11"]) return @"iPad 5";
    if ([platform isEqualToString:@"iPad6,12"]) return @"iPad 5";
    if ([platform isEqualToString:@"iPad7,1" ]) return @"iPad Pro 12.9 Inch 2 Gen";
    if ([platform isEqualToString:@"iPad7,2" ]) return @"iPad Pro 12.9 Inch 2 Gen";
    if ([platform isEqualToString:@"iPad7,3" ]) return @"iPad Pro 10.5 Inch";
    if ([platform isEqualToString:@"iPad7,4" ]) return @"iPad Pro 10.5 Inch";
    if ([platform isEqualToString:@"iPad7,5" ]) return @"iPad 6";
    if ([platform isEqualToString:@"iPad7,6" ]) return @"iPad 6";

    if ([platform isEqualToString:@"iPad7,11" ]) return @"iPad 7";
    if ([platform isEqualToString:@"iPad7,12" ]) return @"iPad 7";

    if ([platform isEqualToString:@"iPad8,1" ]) return @"iPad Pro 11 Inch 3 Gen";
    if ([platform isEqualToString:@"iPad8,2" ]) return @"iPad Pro 11 Inch 3 Gen";
    if ([platform isEqualToString:@"iPad8,3" ]) return @"iPad Pro 11 Inch 3 Gen";
    if ([platform isEqualToString:@"iPad8,4" ]) return @"iPad Pro 11 Inch 3 Gen";
    if ([platform isEqualToString:@"iPad8,5" ]) return @"iPad Pro 12.9 Inch 3 Gen";
    if ([platform isEqualToString:@"iPad8,6" ]) return @"iPad Pro 12.9 Inch 3 Gen";
    if ([platform isEqualToString:@"iPad8,7" ]) return @"iPad Pro 12.9 Inch 3 Gen";
    if ([platform isEqualToString:@"iPad8,8" ]) return @"iPad Pro 12.9 Inch 3 Gen";

    if ([platform isEqualToString:@"iPad8,9" ]) return @"iPad Pro 11 Inch 2 Gen";
    if ([platform isEqualToString:@"iPad8,10" ]) return @"iPad Pro 11 Inch 2 Gen";
    if ([platform isEqualToString:@"iPad8,11" ]) return @"iPad Pro 12.9 Inch 4 Gen";
    if ([platform isEqualToString:@"iPad8,12" ]) return @"iPad Pro 12.9 Inch 4 Gen";

    if ([platform isEqualToString:@"iPad11,1" ]) return @"iPad Mini 5";
    if ([platform isEqualToString:@"iPad11,2" ]) return @"iPad Mini 5";
    if ([platform isEqualToString:@"iPad11,4" ]) return @"iPad Air 3";
    if ([platform isEqualToString:@"iPad11,5" ]) return @"iPad Air 3";
    if ([platform isEqualToString:@"iPad11,6" ]) return @"iPad 8";
    if ([platform isEqualToString:@"iPad11,7" ]) return @"iPad 8";
    
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
    if ([platform isEqualToString:@"iPod9,1"]) return @"iPod touch 7";
    
    return platform;
}


@end
