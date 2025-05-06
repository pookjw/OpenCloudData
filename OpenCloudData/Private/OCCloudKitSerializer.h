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
#import <OpenCloudData/PFMirroredManyToManyRelationshipV2.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@class OCCloudKitSerializer;
@protocol OCCloudKitSerializerDelegate <NSObject>
- (void)cloudKitSerializer:(OCCloudKitSerializer *)cloudKitSerializer failedToUpdateRelationship:(PFMirroredManyToManyRelationshipV2 *)relationship withError:(NSError *)error;
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
+ (CKRecordZoneID *)defaultRecordZoneIDForDatabaseScope:(CKDatabaseScope)databaseScope NS_RETURNS_RETAINED;
+ (BOOL)shouldTrackProperty:(NSPropertyDescription *)property __attribute__((objc_direct));
+ (size_t)estimateByteSizeOfRecordID:(CKRecordID *)recordID __attribute__((objc_direct));
+ (CKRecordType)recordTypeForEntity:(NSEntityDescription *)entity __attribute__((objc_direct));
+ (BOOL)isMirroredRelationshipRecordType:(CKRecordType)recordType __attribute__((objc_direct));

- (instancetype)initWithMirroringOptions:(OCCloudKitMirroringDelegateOptions * _Nullable)mirroringOptions metadataCache:(OCCloudKitMetadataCache *)metadataCache recordNamePrefix:(NSString * _Nullable)recordNamePrefix;

- (NSArray<CKRecord *> * /* 정확하지 않음*/)newCKRecordsFromObject:(NSManagedObject *)object fullyMaterializeRecords:(BOOL)fullyMaterializeRecords includeRelationships:(BOOL)includeRelationships error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
+ (NSSet<NSManagedObjectID *> *)createSetOfObjectIDsRelatedToObject:(NSManagedObject *)object __attribute__((objc_direct)) NS_RETURNS_RETAINED;
+ (NSURL *)generateCKAssetFileURLForObjectInStore:(NSPersistentStore *)store __attribute__((objc_direct));
+ (BOOL)isVariableLengthAttributeType:(NSAttributeType)attributeType __attribute__((objc_direct));
+ (size_t)sizeOfVariableLengthAttribute:(NSAttributeDescription *)attribute withValue:(id)value;
@end

NS_ASSUME_NONNULL_END
