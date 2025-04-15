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

@interface OCCloudKitSerializer : NSObject
+ (CKRecordZoneID *)defaultRecordZoneIDForDatabaseScope:(CKDatabaseScope)databaseScope;
+ (size_t)estimateByteSizeOfRecordID:(CKRecordID *)recordID __attribute__((objc_direct));
+ (CKRecordType)recordTypeForEntity:(NSEntityDescription *)entity __attribute__((objc_direct));

- (instancetype)initWithMirroringOptions:(OCCloudKitMirroringDelegateOptions * _Nullable)mirroringOptions metadataCache:(OCCloudKitMetadataCache *)metadataCache recordNamePrefix:(NSString * _Nullable)recordNamePrefix;
@end

NS_ASSUME_NONNULL_END
