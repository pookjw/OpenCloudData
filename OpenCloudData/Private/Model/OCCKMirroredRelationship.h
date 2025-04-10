//
//  OCCKMirroredRelationship.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/6/25.
//

#import <CoreData/CoreData.h>
#import <OpenCloudData/OCCloudKitImportZoneContext.h>
#import <OpenCloudData/PFMirroredManyToManyRelationshipV2.h>

NS_ASSUME_NONNULL_BEGIN

@class OCCKRecordZoneMetadata;

#warning TODO

@interface OCCKMirroredRelationship : NSManagedObject
+ (NSString *)entityPath;
@property (retain, nonatomic, nullable) NSString *ckRecordID;
@property (retain, nonatomic, nullable) NSData *ckRecordSystemFields;
@property (retain, nonatomic, nullable) NSString *cdEntityName;
@property (retain, nonatomic, nullable) NSString *recordName;
@property (retain, nonatomic, nullable) NSString *relatedEntityName;
@property (retain, nonatomic, nullable) NSString *relatedRecordName;
@property (retain, nonatomic, nullable) NSString *relationshipName;
@property (retain, nonatomic, nullable) NSNumber *isPending;
@property (retain, nonatomic, nullable) NSNumber *needsDelete;
@property (retain, nonatomic, nullable) NSNumber *isUploaded;
@property (retain, nonatomic) OCCKRecordZoneMetadata* recordZone;

- (CKRecordID * _Nullable)createRecordID NS_RETURNS_RETAINED __attribute__((objc_direct));
- (CKRecordID * _Nullable)createRecordIDForRecord NS_RETURNS_RETAINED __attribute__((objc_direct));
- (CKRecordID * _Nullable)createRecordIDForRelatedRecord NS_RETURNS_RETAINED __attribute__((objc_direct));
- (BOOL)updateRelationshipValueUsingImportContext:(OCCloudKitImportZoneContext *)importContext andManagedObjectContext:(NSManagedObjectContext *)managedObjectContext isDelete:(BOOL)isDelete error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));

+ (NSArray<OCCKMirroredRelationship *> * _Nullable)fetchMirroredRelationshipsMatchingRelatingRecords:(NSArray<CKRecord *> *)records andRelatingRecordIDs:(NSArray<CKRecordID *> *)recordIDs fromStore:(__kindof NSPersistentStore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
+ (NSArray<OCCKMirroredRelationship *> * _Nullable)fetchPendingMirroredRelationshipsInStore:(__kindof NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
+ (OCCKMirroredRelationship * _Nullable)mirroredRelationshipForManyToMany:(PFMirroredManyToManyRelationshipV2 *)manyToManyRelationship inStore:(__kindof NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
+ (OCCKMirroredRelationship *)insertMirroredRelationshipForManyToMany:(PFMirroredManyToManyRelationshipV2 *)manyToManyRelationship inZoneWithMetadata:(OCCKRecordZoneMetadata *)metadata inStore:(__kindof NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext __attribute__((objc_direct));
+ (BOOL)purgeMirroredRelationshipsWithRecordIDs:(NSArray<CKRecordID *> *)recordIDs fromStore:(__kindof NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
+ (NSSet<CKRecordID *> * _Nullable)markRelationshipsForDeletedRecordIDs:(NSArray<CKRecordID *> *)deletedRecordIDs inStore:(__kindof NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
+ (BOOL)updateMirroredRelationshipsMatchingRecords:(NSArray<CKRecord *> *)records forStore:(__kindof NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext usingBlock:(BOOL (^ NS_NOESCAPE)(OCCKMirroredRelationship *relationship, CKRecord *record, NSError * _Nullable *error))block error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
+ (NSArray<OCCKMirroredRelationship *> * _Nullable)fetchMirroredRelationshipsMatchingPredicate:(NSPredicate *)predicate fromStore:(__kindof NSPersistentStore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
+ (NSNumber * _Nullable)countMirroredRelationshipsInStore:(__kindof NSPersistentStore *)store matchingPredicate:(NSPredicate *)predicate withManagedObjectContext:(NSManagedObjectContext * _Nullable)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
