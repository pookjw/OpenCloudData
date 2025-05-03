//
//  OCCloudKitMirroringDelegatePreJazzkonMetadata.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/3/25.
//

#import <CoreData/CoreData.h>
#import <CloudKit/CloudKit.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCCloudKitMirroringDelegatePreJazzkonMetadata : NSObject
- (instancetype)initWithStore:(NSPersistentStore *)store;
- (BOOL)load:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
- (CKServerChangeToken *)changeTokenForDatabaseScope:(CKDatabaseScope)databaseScope __attribute__((objc_direct));
- (BOOL)hasInitializedDatabaseSubscription __attribute__((objc_direct));
- (CKServerChangeToken *)changeTokenForZoneWithID:(CKRecordZoneID *)zoneID inDatabaseWithScope:(CKDatabaseScope)databaseScope __attribute__((objc_direct));
- (NSPersistentHistoryToken * _Nullable)lastHistoryToken __attribute__((objc_direct));
- (NSString * _Nullable)ckIdentityRecordName __attribute__((objc_direct));
- (BOOL)hasCheckedCKIdentity __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
