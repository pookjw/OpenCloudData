//
//  NSPersistentStoreCoordinator+Private.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/5/25.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSPersistentStoreCoordinator (Private)
- (__kindof NSPersistentStore * _Nullable)persistentStoreForIdentifier:(NSString *)identifier;
@end

NS_ASSUME_NONNULL_END
