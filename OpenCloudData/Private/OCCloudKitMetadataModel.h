//
//  OCCloudKitMetadataModel.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/6/25.
//

#import <CoreData/CoreData.h>
#import <OpenCloudData/_PFAncillaryModelFactory.h>
#import <OpenCloudData/OpenCloudDataDefines.h>
#import <OpenCloudData/NSSQLiteConnection.h>

NS_ASSUME_NONNULL_BEGIN

OC_PRIVATE_EXTERN NSString * const OCCKRecordIDAttributeName;
OC_PRIVATE_EXTERN NSString * const OCCKRecordZoneQueryCursorTransformerName;
OC_PRIVATE_EXTERN NSString * const OCCKRecordZoneQueryPredicateTransformerName;

@interface OCCloudKitMetadataModel : NSObject <_PFAncillaryModelFactory>
+ (NSDictionary<NSNumber *, NSSet<NSNumber *> *> *)createMapOfEntityIDToPrimaryKeySetForObjectIDs:(NSObject<NSFastEnumeration> *)objectIDs NS_RETURNS_RETAINED;
+ (NSDictionary<NSNumber *, NSSet<NSNumber *> *> *)createMapOfEntityIDToPrimaryKeySetForObjectIDs:(NSObject<NSFastEnumeration> *)objectIDs fromStore:(__kindof NSPersistentStore * _Nullable)store NS_RETURNS_RETAINED;
+ (NSManagedObjectModel *)newMetadataModelForFrameworkVersion:(NSNumber *)version __attribute__((objc_direct));
+ (BOOL)checkAndRepairSchemaOfStore:(NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
+ (NSManagedObjectModel * _Nullable)identifyModelForStore:(NSPersistentStore *)store withConnection:(NSSQLiteConnection *)connection hasOldMetadataTables:(BOOL * _Nullable)hasOldMetadataTables __attribute__((objc_direct)) NS_RETURNS_RETAINED;
@end

NS_ASSUME_NONNULL_END
