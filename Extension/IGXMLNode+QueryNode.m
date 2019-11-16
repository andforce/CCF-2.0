//
// Created by WDY on 2016/12/2.
// Copyright (c) 2016 andforce. All rights reserved.
//

#import "IGXMLNode+QueryNode.h"


@implementation IGXMLNode (QueryNode)

- (IGXMLNode *)queryNodeWithXPath:(NSString *)xpath {
    return [self queryWithXPath:xpath].firstObject;
}

// http://stackoverflow.com/questions/1604471/how-can-i-find-an-element-by-css-class-with-xpath
- (IGXMLNode *)queryNodeWithClassName:(NSString *)name {
    NSString *xpath = [NSString stringWithFormat:@"//*[contains(concat('  ', normalize-space(@class), '  '), '  %@  ')]", name];
    IGXMLNode *node = [self queryNodeWithXPath:xpath];
    return node;
}

- (IGXMLNodeSet *)queryWithClassName:(NSString *)name {
    NSString *xpath = [NSString stringWithFormat:@"//*[contains(concat('  ', normalize-space(@class), '  '), '  %@  ')]", name];
    IGXMLNodeSet *node = [self queryWithXPath:xpath];
    return node;
}


@end