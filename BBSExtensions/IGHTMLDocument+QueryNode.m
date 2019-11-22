//
//  IGHTMLDocument+QueryNode.m
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "IGHTMLDocument+QueryNode.h"

@implementation IGHTMLDocument (QueryNode)

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
    IGXMLNodeSet *set = [self queryWithXPath:xpath];
    return set;
}

@end
