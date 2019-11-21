//
//  CoreDataManager.h
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef void(^Operation)(NSManagedObject *target, id src);


typedef void(^InsertOperation)(id src);

typedef NSPredicate *(^Predicate)();


@interface CoreDataManager : NSObject

@property(readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property(readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property(readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (instancetype)initWithXcdatamodeld:(NSString *)name andWithPersistentName:(NSString *)persistentName andWithEntryName:(NSString *)entryName;

- (void)saveContext;

//插入数据
//- (void)insertData:(NSMutableArray*)dataArray;

- (void)insertData:(NSMutableArray *)dataArray operation:(Operation)operation;

- (void)insertOneData:(InsertOperation)operation;


// 取出所有的数据
- (NSArray *)selectData;

- (NSArray *)selectData:(Predicate)operation;

- (void)deleteData:(Predicate)operation;


//查询
- (NSArray *)selectData:(int)pageSize andOffset:(int)currentPage;

//删除
- (void)deleteData;

//更新
- (void)updateData:(NSString *)newsId withIsLook:(NSString *)islook;

@end