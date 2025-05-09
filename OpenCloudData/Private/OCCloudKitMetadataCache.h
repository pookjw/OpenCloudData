//
//  OCCloudKitMetadataCache.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/15/25.
//

#import <CloudKit/CloudKit.h>
#import <CoreData/CoreData.h>
#import <OpenCloudData/NSSQLCore.h>
#import <OpenCloudData/OCCloudKitMirroringDelegateOptions.h>
#import <OpenCloudData/OCCKMirroredRelationship.h>
#import <OpenCloudData/OCCKRecordMetadata.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCCloudKitMetadataCache : NSObject {
    @package NSMutableDictionary<CKRecordZoneID *, OCCKRecordZoneMetadata *> *_recordZoneIDToZoneMetadata; // 0x8
    @package NSMutableDictionary<NSManagedObjectID *, OCCKRecordMetadata *> *_objectIDToRecordMetadata; // 0x10
    @package NSMutableDictionary<CKRecordZoneID *, NSMutableDictionary<NSString *, OCCKMirroredRelationship *> *> *_zoneIDToMtmKeyToMirroredRelationship; // 0x20
    @package NSMutableDictionary<NSManagedObjectID *, NSMutableDictionary<NSString *, NSMutableSet<NSString *> *> *> *_objectIDToRelationshipNameToExistingMTMKeys; // 0x28
    @package NSMutableDictionary<NSManagedObjectID *, NSMutableArray<NSString *> *> *_objectIDToChangedPropertyKeys; // 0x30
    @package NSMutableSet<CKRecordZoneID *> *_mutableZoneIDs; // 0x40
}
- (BOOL)cacheMetadataForObjectsWithIDs:(NSArray<NSManagedObjectID *> *)objectIDs andRecordsWithIDs:(NSArray *)recordsWithIDs inStore:(NSSQLCore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext mirroringOptions:(OCCloudKitMirroringDelegateOptions * _Nullable)mirroringOptions error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
- (void)registerRecordMetadata:(OCCKRecordMetadata *)recordMetadata forObject:(NSManagedObject *)object __attribute__((objc_direct));
- (void)cacheZoneMetadata:(OCCKRecordZoneMetadata *)zoneMetadata __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
