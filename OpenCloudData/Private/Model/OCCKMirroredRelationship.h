//
//  OCCKMirroredRelationship.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/6/25.
//

#import <CoreData/CoreData.h>
#import <OpenCloudData/OCCloudKitImportZoneContext.h>

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

+ (NSArray *)fetchMirroredRelationshipsMatchingRelatingRecords:(NSArray<CKRecord *> *)records andRelatingRecordIDs:(NSArray<CKRecordID *> *)recordIDs fromStore:(__kindof NSPersistentStore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
