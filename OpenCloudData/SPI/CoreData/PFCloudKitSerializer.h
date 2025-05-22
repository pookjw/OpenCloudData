//
//  PFCloudKitSerializer.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/8/25.
//

#import <CloudKit/CloudKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PFCloudKitSerializer : NSObject
+ (CKRecordZoneID *)defaultRecordZoneIDForDatabaseScope:(CKDatabaseScope)databaseScope NS_RETURNS_RETAINED;
@end

NS_ASSUME_NONNULL_END
