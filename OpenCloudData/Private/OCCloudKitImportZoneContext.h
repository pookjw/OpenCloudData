//
//  OCCloudKitImportZoneContext.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/6/25.
//

#import <CloudKit/CloudKit.h>
#import <CoreData/CoreData.h>
#import <OpenCloudData/OCCloudKitMirroringDelegateOptions.h>
#import <OpenCloudData/OCMirroredOneToManyRelationship.h>
#import <OpenCloudData/OCMirroredManyToManyRelationshipV2.h>
#import <OpenCloudData/OCCKRecordMetadata.h>

#warning TODO

NS_ASSUME_NONNULL_BEGIN

@class OCCKImportOperation;

@interface OCCloudKitImportZoneContext : NSObject {
    NSArray<CKRecord *> *_updatedRecords; // 0x8
    NSDictionary<NSString *, NSArray<CKRecordID *> *> *_deletedRecordTypeToRecordID; // 0x10
    @package NSSet<NSManagedObjectID *> *_deletedObjectIDs; // 0x18
    @package NSArray<CKRecord *> *_modifiedRecords; // 0x20
    @package NSMutableArray<OCMirroredManyToManyRelationship *> *_updatedRelationships; // 0x28
    @package NSArray<OCMirroredManyToManyRelationship *> *_deletedRelationships; // 0x30
    // ivar 상으로는 NSArray이지만 NSSet으로 다뤄야 한다. https://x.com/_silgen_name/status/1921235608715853962
    @package NSArray<CKRecordID *> *_deletedMirroredRelationshipRecordIDs; // 0x38
    @package NSMutableDictionary<CKRecordType, NSMutableDictionary<CKRecordID *, NSManagedObjectID *> *> *_recordTypeToRecordIDToObjectID; // 0x40
    NSMutableDictionary<CKRecordType, NSMutableArray<CKRecordID *> *> *_recordTypeToUnresolvedRecordIDs; // 0x48
    NSMutableArray *_metadatasToLink; // 0x50
    NSArray<OCCKImportOperation *> *_importOperations; // 0x58
    OCCloudKitMirroringDelegateOptions *_mirroringOptions; // 0x60
    NSURL * _Nullable _fileBackedFuturesDirectory; // 0x68
    @package NSSet<CKRecordID *> *_deletedShareRecordIDs; // 0x70
}
- (instancetype)initWithUpdatedRecords:(NSArray<CKRecord *> *)updatedRecords deletedRecordTypeToRecordIDs:(NSDictionary<NSString *, NSArray<CKRecordID *> *> *)deletedRecordTypeToRecordIDs options:(OCCloudKitMirroringDelegateOptions *)options fileBackedFuturesDirectory:(NSString * _Nullable)fileBackedFuturesDirectory;
- (BOOL)initializeCachesWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext andObservedStore:(NSSQLCore *)observedStore error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
- (void)registerObject:(NSManagedObject *)object forInsertedRecord:(CKRecord *)record withMetadata:(OCCKRecordMetadata *)metadata __attribute__((objc_direct));
- (void)addMirroredRelationshipToLink:(OCMirroredOneToManyRelationship *)mirroredRelationship  __attribute__((objc_direct));
- (BOOL)linkInsertedObjectsAndMetadataInContext:(NSManagedObjectContext *)context error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
- (BOOL)populateUnresolvedIDsInStore:(NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
- (void)addObjectID:(NSManagedObjectID *)objectID toCache:(NSMutableDictionary *)cache andRecordID:(CKRecordID *)recordID __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
