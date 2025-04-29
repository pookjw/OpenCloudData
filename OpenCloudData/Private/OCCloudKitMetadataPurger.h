//
//  OCCloudKitMetadataPurger.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/22/25.
//

#import <OpenCloudData/OCCloudKitStoreMonitor.h>
#import <OpenCloudData/OCCloudKitMirroringRequest.h>
#import <OpenCloudData/NSSQLCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitMetadataPurger : NSObject
- (BOOL)purgeMetadataFromStore:(NSSQLCore *)store inMonitor:(OCCloudKitStoreMonitor *)monitor withOptions:(NSUInteger)options forRecordZones:(NSArray<CKRecordZoneID *> *)recordZones inDatabaseWithScope:(CKDatabaseScope)databaseScope andTransactionAuthor:(NSString *)transactionAuthor error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
- (BOOL)purgeMetadataMatchingObjectIDs:(NSSet<NSManagedObjectID *> *)objectIDs inRequest:(__kindof OCCloudKitMirroringRequest *)request inStore:(NSSQLCore *)store withMonitor:(OCCloudKitStoreMonitor *)monitor error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
- (BOOL)purgeMetadataAfterAccountChangeFromStore:(NSSQLCore *)store inMonitor:(OCCloudKitStoreMonitor *)monitor inDatabaseWithScope:(CKDatabaseScope)databaseScope error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
- (BOOL)deleteZoneMetadataFromStore:(NSSQLCore *)store inMonitor:(OCCloudKitStoreMonitor *)monitor forRecordZones:(NSArray<CKRecordZoneID *> *)recordZones inDatabaseWithScope:(CKDatabaseScope)databaseScope error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
