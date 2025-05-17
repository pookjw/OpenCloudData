//
//  OCCloudKitSerializer.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/12/25.
//

#import <CoreData/CoreData.h>
#import <CloudKit/CloudKit.h>
#import <OpenCloudData/OCCloudKitMirroringDelegateOptions.h>
#import <OpenCloudData/OCCloudKitMetadataCache.h>
#import <OpenCloudData/OCCKRecordMetadata.h>

NS_ASSUME_NONNULL_BEGIN

@class OCCloudKitSerializer;
@protocol OCCloudKitSerializerDelegate <NSObject>
- (void)cloudKitSerializer:(OCCloudKitSerializer *)cloudKitSerializer failedToUpdateRelationship:(OCMirroredManyToManyRelationship *)relationship withError:(NSError *)error;
- (NSURL * _Nullable)cloudKitSerializer:(OCCloudKitSerializer *)cloudKitSerializer safeSaveURLForAsset:(CKAsset *)asset;
@end

@interface OCCloudKitSerializer : NSObject {
    NSMutableDictionary<NSString *, CKRecord *> *_manyToManyRecordNameToRecord; // 0x8
    NSString *_recordNamePrefix; // 0x10
    OCCloudKitMirroringDelegateOptions *_mirroringOptions; // 0x18
    __weak NSObject<OCCloudKitSerializerDelegate> *_delegate; // 0x20
    @package NSMutableArray<NSURL *> *_writtenAssetURLs; // 0x28
    OCCloudKitMetadataCache *_metadataCache; // 0x30
    CKRecordZone *_recordZone; // 0x38
}
@property (weak, nonatomic, nullable, direct) NSObject<OCCloudKitSerializerDelegate> *delegate;
+ (CKRecordZoneID *)defaultRecordZoneIDForDatabaseScope:(CKDatabaseScope)databaseScope NS_RETURNS_RETAINED;
+ (BOOL)shouldTrackProperty:(NSPropertyDescription *)property __attribute__((objc_direct));
+ (size_t)estimateByteSizeOfRecordID:(CKRecordID *)recordID __attribute__((objc_direct));
+ (CKRecordType)recordTypeForEntity:(NSEntityDescription *)entity __attribute__((objc_direct));
+ (BOOL)isMirroredRelationshipRecordType:(CKRecordType)recordType __attribute__((objc_direct));
+ (NSSet<NSManagedObjectID *> *)createSetOfObjectIDsRelatedToObject:(NSManagedObject *)object __attribute__((objc_direct)) NS_RETURNS_RETAINED;
+ (NSURL *)generateCKAssetFileURLForObjectInStore:(NSPersistentStore *)store __attribute__((objc_direct));
+ (NSURL *)assetStorageDirectoryURLForStore:(NSPersistentStore *)store __attribute__((objc_direct));
+ (NSURL *)oldAssetStorageDirectoryURLForStore:(NSPersistentStore *)store __attribute__((objc_direct));
+ (BOOL)isVariableLengthAttributeType:(NSAttributeType)attributeType __attribute__((objc_direct));
+ (size_t)sizeOfVariableLengthAttribute:(NSAttributeDescription *)attribute withValue:(id _Nullable)value __attribute__((objc_direct));
+ (NSString *)mtmKeyForObjectWithRecordName:(NSString *)recordName relatedToObjectWithRecordName:(NSString *)relatedToObjectWithRecordName byRelationship:(NSRelationshipDescription *)relationship withInverse:(NSRelationshipDescription *)inverseRelationship __attribute__((objc_direct));
+ (NSString *)applyCDPrefixToName:(NSString *)name __attribute__((objc_direct));
+ (BOOL)isPrivateAttribute:(NSAttributeDescription *)attribute __attribute__((objc_direct));
+ (NSArray<CKAsset *> *)assetsOnRecord:(CKRecord *)record withOptions:(OCCloudKitMirroringDelegateOptions *)options __attribute__((objc_direct));
+ (NSSet<NSString *> *)newSetOfRecordKeysForEntitiesInConfiguration:(NSString *)configurationName inManagedObjectModel:(NSManagedObjectModel *)managedObjectModel includeCKAssetsForFileBackedFutures:(BOOL)includeCKAssetsForFileBackedFutures __attribute__((objc_direct));
+ (NSSet<NSString *> *)newSetOfRecordKeysForAttribute:(NSAttributeDescription *)attribute includeCKAssetsForFileBackedFutures:(BOOL)includeCKAssetsForFileBackedFutures __attribute__((objc_direct));

- (instancetype)initWithMirroringOptions:(OCCloudKitMirroringDelegateOptions * _Nullable)mirroringOptions metadataCache:(OCCloudKitMetadataCache *)metadataCache recordNamePrefix:(NSString * _Nullable)recordNamePrefix;

- (NSArray<CKRecord *> * _Nullable)newCKRecordsFromObject:(NSManagedObject *)object fullyMaterializeRecords:(BOOL)fullyMaterializeRecords includeRelationships:(BOOL)includeRelationships error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
- (OCCKRecordMetadata * _Nullable)getRecordMetadataForObject:(NSManagedObject *)managedObject inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
- (BOOL)shouldEncryptValueForAttribute:(NSAttributeDescription *)attribute __attribute__((objc_direct));
- (BOOL)applyUpdatedRecords:(NSArray<CKRecord *> *)updatedRecords deletedRecordIDs:(NSDictionary<NSString *, NSArray<CKRecordID *> *> *)deletedRecordIDs toStore:(NSSQLCore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext onlyUpdatingAttributes:(NSDictionary<NSString *, NSArray<NSAttributeDescription *> *> * _Nullable)onlyUpdatingAttributes andRelationships:(NSDictionary<NSString *, NSArray<NSRelationshipDescription *> *> * _Nullable)relationships madeChanges:(BOOL * _Nullable)madeChanges error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
- (BOOL)updateAttributes:(NSArray<NSAttributeDescription *> * _Nullable)attributes andRelationships:(NSArray<NSRelationshipDescription *> * _Nullable)relationships onManagedObject:(NSManagedObject *)managedObject fromRecord:(CKRecord *)record withRecordMetadata:(OCCKRecordMetadata *)recordMetadata importContext:(OCCloudKitImportZoneContext *)importContext error:(NSError * _Nullable * _Nonnull)error __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
