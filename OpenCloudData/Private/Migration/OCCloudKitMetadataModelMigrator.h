//
//  OCCloudKitMetadataModelMigrator.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/29/25.
//

#import <CoreData/CoreData.h>
#import <CloudKit/CloudKit.h>
#import "OpenCloudData/Private/OCCloudKitMetricsClient.h"
#import "OpenCloudData/SPI/CoreData/NSSQLCore.h"
#import "OpenCloudData/Private/Migration/OCCloudKitMetadataMigrationContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitMetadataModelMigrator : NSObject {
    NSSQLCore *_store; // 0x8
    NSManagedObjectContext *_metadataContext; // 0x10
    OCCloudKitMetadataMigrationContext *_context; // 0x18
    CKDatabaseScope _databaseScope; // 0x20
    OCCloudKitMetricsClient *_metricsClient; // 0x28
}
- (instancetype)initWithStore:(NSSQLCore *)store metadataContext:(NSManagedObjectContext *)metadataContext databaseScope:(CKDatabaseScope)databaseScope metricsClient:(OCCloudKitMetricsClient *)metricsClient;
- (BOOL)checkAndPerformMigrationIfNecessary:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
