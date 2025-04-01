//
//  NSPersistentContainer+Private.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSPersistentContainer (Private)
- (void)_loadStoreDescriptions:(NSArray<NSPersistentStoreDescription *> *)storeDescriptions withCompletionHandler:(void (^)(NSPersistentStoreDescription *, NSError * _Nullable))completionHandler;
@end

NS_ASSUME_NONNULL_END
