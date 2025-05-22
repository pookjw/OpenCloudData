//
//  OCCloudKitMirroringDelegatePreJazzkonMetadata.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/3/25.
//

#import <CoreData/CoreData.h>
#import <CloudKit/CloudKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitMirroringDelegatePreJazzkonMetadata : NSObject {
    __weak NSPersistentStore * _Nullable _store; // 0x8
    BOOL _loaded; // 0x10
    BOOL _hasChanges; // 0x11
    BOOL _hasInitializedZone; // 0x12
    BOOL _hasInitializedZoneSubscription; // 0x13
    BOOL _hasInitializedDatabaseSubscription; // 0x14
    NSString *_ckIdentityRecordName; // 0x18
    BOOL _hasCheckedCKIdentity; // 0x20
    NSDictionary<NSString *, CKServerChangeToken *> *_keyToPreviousServerChangeToken; // 0x28
    NSPersistentHistoryToken *_lastHistoryToken; // 0x30
}
+ (NSArray<NSString *> *)allDefaultsKeys __attribute__((objc_direct));
- (instancetype)initWithStore:(NSPersistentStore *)store;
- (BOOL)load:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
- (CKServerChangeToken * _Nullable)changeTokenForDatabaseScope:(CKDatabaseScope)databaseScope __attribute__((objc_direct));
- (BOOL)hasInitializedDatabaseSubscription __attribute__((objc_direct));
- (CKServerChangeToken * _Nullable)changeTokenForZoneWithID:(CKRecordZoneID *)zoneID inDatabaseWithScope:(CKDatabaseScope)databaseScope __attribute__((objc_direct));
- (NSPersistentHistoryToken * _Nullable)lastHistoryToken __attribute__((objc_direct));
- (NSString * _Nullable)ckIdentityRecordName __attribute__((objc_direct));
- (BOOL)hasCheckedCKIdentity __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
