//
//  IGXMLNode+Children.m
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "IGXMLNode+Children.h"

@implementation IGXMLNode (Children)

- (IGXMLNode *)childAt:(int)position {
    return self.children[position];
}

- (int)childrenCount {
    return (int) [self.children count];
}
@end
