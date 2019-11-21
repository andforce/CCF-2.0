//
//  IGHTMLDocument+QueryNode.h
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <IGHTMLQuery/IGHTMLQuery.h>

@interface IGHTMLDocument (QueryNode)

- (IGXMLNode *)queryNodeWithXPath:(NSString *)xpath;

- (IGXMLNode *)queryNodeWithClassName:(NSString *)name;

- (IGXMLNodeSet *)queryWithClassName:(NSString *)name;

@end
