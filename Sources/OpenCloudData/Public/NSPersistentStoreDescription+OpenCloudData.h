//
//  NSPersistentStoreDescription+OpenCloudData.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@class OCPersistentCloudKitContainerOptions;

@interface NSPersistentStoreDescription (OpenCloudData)
@property (strong, nullable, setter=oc_setCloudKitContainerOptions:) OCPersistentCloudKitContainerOptions *oc_cloudKitContainerOptions;
@end

NS_ASSUME_NONNULL_END
