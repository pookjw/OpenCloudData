//
//  NSPersistentStore+Private.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import <CoreData/CoreData.h>
#import "OpenCloudData/SPI/CoreData/NSPersistentStoreMirroringDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSPersistentStore (Private)
- (NSObject<NSPersistentStoreMirroringDelegate> * _Nullable)mirroringDelegate;
- (NSPersistentStoreCoordinator * _Nullable)_persistentStoreCoordinator;
@end

NS_ASSUME_NONNULL_END
