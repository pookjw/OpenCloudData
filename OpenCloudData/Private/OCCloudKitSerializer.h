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

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCCloudKitSerializer : NSObject {
    @package NSMutableArray *_writtenAssetURLs; // 0x28
}
+ (CKRecordZoneID *)defaultRecordZoneIDForDatabaseScope:(CKDatabaseScope)databaseScope NS_RETURNS_RETAINED;
+ (size_t)estimateByteSizeOfRecordID:(CKRecordID *)recordID __attribute__((objc_direct));
+ (CKRecordType)recordTypeForEntity:(NSEntityDescription *)entity __attribute__((objc_direct));
+ (BOOL)isMirroredRelationshipRecordType:(CKRecordType)recordType __attribute__((objc_direct));

- (instancetype)initWithMirroringOptions:(OCCloudKitMirroringDelegateOptions * _Nullable)mirroringOptions metadataCache:(OCCloudKitMetadataCache *)metadataCache recordNamePrefix:(NSString * _Nullable)recordNamePrefix;

- (NSArray<CKRecord *> * /* 정확하지 않음*/)newCKRecordsFromObject:(NSManagedObject *)object fullyMaterializeRecords:(BOOL)fullyMaterializeRecords includeRelationships:(BOOL)includeRelationships error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
+ (NSSet<NSManagedObjectID *> *)createSetOfObjectIDsRelatedToObject:(NSManagedObject *)object __attribute__((objc_direct)) NS_RETURNS_RETAINED;
@end

NS_ASSUME_NONNULL_END
