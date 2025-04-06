//
//  OCCKDatabaseMetadata.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/5/25.
//

#import <CloudKit/CloudKit.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@class OCCKRecordZoneMetadata;

@interface OCCKDatabaseMetadata : NSManagedObject
+ (OCCKDatabaseMetadata * _Nullable)databaseMetadataForScope:(CKDatabaseScope)databaseScope forStore:(__kindof NSPersistentStore *)store inContext:(NSManagedObjectContext *)context error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
+ (NSString *)entityPath;
@property (retain, nonatomic, nullable) NSNumber *hasSubscriptionNum;
@property (retain, nonatomic) NSNumber *databaseScopeNum;
@property (retain, nonatomic) NSString *databaseName;
@property (nonatomic) CKDatabaseScope databaseScope;
@property (retain, nonatomic, nullable) CKServerChangeToken *currentChangeToken;
@property (retain, nonatomic, nullable) NSDate *lastFetchDate;
@property (nonatomic) BOOL hasSubscription;
@property (retain, nonatomic, nullable) NSSet<OCCKRecordZoneMetadata *> *recordZones;
@end

NS_ASSUME_NONNULL_END
