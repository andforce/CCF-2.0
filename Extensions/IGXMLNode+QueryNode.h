//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2016 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IGXMLNode.h"

@interface IGXMLNode (QueryNode)

- (IGXMLNode *)queryNodeWithXPath:(NSString *)xpath;

- (IGXMLNode *)queryNodeWithClassName:(NSString *)name;

- (IGXMLNodeSet *)queryWithClassName:(NSString *)name;

@end