//
//  OCCloudKitMetadataModel.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/6/25.
//

#import <CoreData/CoreData.h>
#import <OpenCloudData/_PFAncillaryModelFactory.h>
#import <OpenCloudData/OpenCloudDataDefines.h>

NS_ASSUME_NONNULL_BEGIN

OC_PRIVATE_EXTERN NSString * const OCCKRecordIDAttributeName;

#warning TODO

@interface OCCloudKitMetadataModel : NSObject <_PFAncillaryModelFactory>
+ (NSDictionary<NSNumber *, NSSet<NSNumber *> *> *)createMapOfEntityIDToPrimaryKeySetForObjectIDs:(NSObject<NSFastEnumeration> *)objectIDs NS_RETURNS_RETAINED;
+ (NSDictionary<NSNumber *, NSSet<NSNumber *> *> *)createMapOfEntityIDToPrimaryKeySetForObjectIDs:(NSObject<NSFastEnumeration> *)objectIDs fromStore:(__kindof NSPersistentStore * _Nullable)store NS_RETURNS_RETAINED;
+ (NSManagedObjectModel *)newMetadataModelForFrameworkVersion:(NSNumber *)version __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
