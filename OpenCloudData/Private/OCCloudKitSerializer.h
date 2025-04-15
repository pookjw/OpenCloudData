//
//  OCCloudKitSerializer.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/12/25.
//

#import <CoreData/CoreData.h>
#import <CloudKit/CloudKit.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCCloudKitSerializer : NSObject
+ (CKRecordZoneID *)defaultRecordZoneIDForDatabaseScope:(CKDatabaseScope)databaseScope;
+ (size_t)estimateByteSizeOfRecordID:(CKRecordID *)recordID __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
