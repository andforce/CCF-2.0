//
//  CoreDataManager.m
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BBSDataManager.h"
#import "ForumEntry+CoreDataClass.h"

@implementation BBSDataManager {
    NSString *_xcdatamodeld;
    NSString *_persistent;
    NSString *_entry;
}


@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (instancetype)initWithXcdatamodeld:(NSString *)name andWithPersistentName:(NSString *)persistentName andWithEntryName:(NSString *)entryName {
    if (self = [super init]) {
        _xcdatamodeld = name;
        _persistent = persistentName;
        _entry = entryName;

    }
    return self;
}


- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:_xcdatamodeld withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:_persistent];

    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.获取Documents路径
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

//插入数据
- (void)insertData:(NSMutableArray *)dataArray {
    NSManagedObjectContext *context = [self managedObjectContext];
    for (NSManagedObject *info in dataArray) {


        NSManagedObject *needInsert = [NSEntityDescription insertNewObjectForEntityForName:_entry inManagedObjectContext:context];

        ForumEntry *newsInfo = (ForumEntry *) needInsert;
        newsInfo.forumId = [info valueForKey:@"forumId"];
        newsInfo.forumName = [info valueForKey:@"forumName"];
        newsInfo.parentForumId = [info valueForKey:@"parentForumId"];

        NSError *error;
        if (![context save:&error]) {
            NSLog(@"不能保存：%@", [error localizedDescription]);
        }
    }
}

- (void)insertData:(NSMutableArray *)dataArray operation:(Operation)operation {
    NSManagedObjectContext *context = [self managedObjectContext];
    for (NSManagedObject *info in dataArray) {


        NSManagedObject *needInsert = [NSEntityDescription insertNewObjectForEntityForName:_entry inManagedObjectContext:context];

        operation(needInsert, info);

        NSError *error;
        if (![context save:&error]) {
            NSLog(@"不能保存：%@", [error localizedDescription]);
        }
    }
}

- (void)insertOneData:(InsertOperation)operation {
    NSManagedObjectContext *context = [self managedObjectContext];

    NSManagedObject *needInsert = [NSEntityDescription insertNewObjectForEntityForName:_entry inManagedObjectContext:context];

    operation(needInsert);

    NSError *error;
    if (![context save:&error]) {
        NSLog(@"不能保存：%@", [error localizedDescription]);
    }
}


//查询
- (NSMutableArray *)selectData:(int)pageSize andOffset:(int)currentPage {
    NSManagedObjectContext *context = [self managedObjectContext];

    // 限定查询结果的数量
    //setFetchLimit
    // 查询的偏移量
    //setFetchOffset

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    [fetchRequest setFetchLimit:pageSize];
    [fetchRequest setFetchOffset:currentPage];

    NSEntityDescription *entity = [NSEntityDescription entityForName:_entry inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    NSMutableArray *resultArray = [NSMutableArray array];

    for (ForumEntry *info in fetchedObjects) {
        NSLog(@"forumName:%@", info.forumName);
        NSLog(@"forumId:%@", info.forumId);
        [resultArray addObject:info];
    }
    return resultArray;
}

- (void)deleteData:(Predicate)operation {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];


    NSEntityDescription *entity = [NSEntityDescription entityForName:_entry inManagedObjectContext:context];
    [fetchRequest setEntity:entity];

    NSPredicate *predicate = operation();
    if (predicate != nil) {
        [fetchRequest setPredicate:predicate];
    }

    NSError *error;
    NSArray *datas = [context executeFetchRequest:fetchRequest error:&error];
    if (!error && datas && [datas count]) {
        for (NSManagedObject *obj in datas) {
            [context deleteObject:obj];
        }
        if (![context save:&error]) {
            NSLog(@"error:%@", error);
        }
    }

}

//删除
- (void)deleteData {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:_entry inManagedObjectContext:context];

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setIncludesPropertyValues:NO];
    [request setEntity:entity];
    NSError *error = nil;
    NSArray *datas = [context executeFetchRequest:request error:&error];
    if (!error && datas && [datas count]) {
        for (NSManagedObject *obj in datas) {
            [context deleteObject:obj];
        }
        if (![context save:&error]) {
            NSLog(@"error:%@", error);
        }
    }
}

//更新
- (void)updateData:(NSString *)newsId withIsLook:(NSString *)islook {
    NSManagedObjectContext *context = [self managedObjectContext];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"newsid like[cd] %@", newsId];

    //首先你需要建立一个request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:_entry inManagedObjectContext:context]];
    [request setPredicate:predicate];//这里相当于sqlite中的查询条件，具体格式参考苹果文档 https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/Predicates/Articles/pCreating.html
    NSError *error = nil;

    //保存
    if ([context save:&error]) {
        //更新成功
        NSLog(@"更新成功");
    }
}

- (NSMutableArray *)selectData {
    NSManagedObjectContext *context = [self managedObjectContext];

    // 限定查询结果的数量
    //setFetchLimit
    // 查询的偏移量
    //setFetchOffset

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];


    NSEntityDescription *entity = [NSEntityDescription entityForName:_entry inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    NSMutableArray *resultArray = [NSMutableArray array];

    [resultArray addObjectsFromArray:fetchedObjects];

    return resultArray;
}

- (NSArray *)selectData:(Predicate)operation {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];


    NSEntityDescription *entity = [NSEntityDescription entityForName:_entry inManagedObjectContext:context];
    [fetchRequest setEntity:entity];

    NSPredicate *predicate = operation();
    if (predicate != nil) {
        [fetchRequest setPredicate:predicate];
    }

    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];


    return fetchedObjects;
}


@end
