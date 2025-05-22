//
//  NSPersistentStoreMirroringDelegate.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NSPersistentStoreMirroringDelegate <NSObject>
- (void)persistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator didSuccessfullyAddPersistentStore:(__kindof NSPersistentStore *)persistentStore withDescription:(NSPersistentStoreDescription *)storeDescription;
- (BOOL)validateManagedObjectModel:(NSManagedObjectModel *)managedObjectModel forUseWithStoreWithDescription:(NSPersistentStoreDescription *)storeDescription error:(NSError * _Nullable * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
