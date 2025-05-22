//
//  OCCloudKitExporter.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/4/25.
//

#import <CloudKit/CloudKit.h>
#import "OpenCloudData/Private/Request/OCCloudKitMirroringRequest.h"
#import "OpenCloudData/Private/Export/OCCloudKitExporterOptions.h"
#import "OpenCloudData/Private/OCCloudKitStoreMonitor.h"
#import "OpenCloudData/Private/Export/OCCloudKitExportContext.h"
#import "OpenCloudData/Private/Request/OCCloudKitMirroringResult.h"

NS_ASSUME_NONNULL_BEGIN

@class OCCloudKitExporter;
@protocol OCCloudKitExporterDelegate <NSObject>
- (void)exporter:(OCCloudKitExporter *)exporter willScheduleOperations:(NSArray<__kindof CKOperation *> *)operations;
@end

@interface OCCloudKitExporter : NSObject {
    NSMutableDictionary<NSString *, OCCloudKitMirroringResult *> *_operationIDToResult;
    void (^ _exportCompletionBlock)(OCCloudKitMirroringResult *result);
    OCCloudKitExporterOptions *_options;
    dispatch_queue_t _workQueue;
    __kindof OCCloudKitMirroringRequest * _Nullable _request;
    __weak NSObject<OCCloudKitExporterDelegate> *_delegate;
    OCCloudKitExportContext *_exportContext;
    OCCloudKitStoreMonitor *_monitor;
}
- (instancetype)initWithOptions:(OCCloudKitExporterOptions *)options request:(__kindof OCCloudKitMirroringRequest * _Nullable)request monitor:(OCCloudKitStoreMonitor *)monitor workQueue:(dispatch_queue_t)workQueue;
- (void)exportIfNecessaryWithCompletion:(void (^ _Nullable)(OCCloudKitMirroringResult *result))completion __attribute__((objc_direct));
- (void)checkForZonesNeedingExport __attribute__((objc_direct));
- (void)finishExportWithResult:(OCCloudKitMirroringResult *)result __attribute__((objc_direct));
- (BOOL)updateMetadataForSavedZones:(NSArray<CKRecordZone *> *)savedZones error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
- (void)exportIfNecessary __attribute__((objc_direct));
- (void)fetchRecordZones:(NSArray<CKRecordZoneID *> *)zoneIDs __attribute__((objc_direct));
- (BOOL)analyzeHistoryInStore:(__kindof NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
- (void)executeOperation:(CKModifyRecordsOperation *)operation __attribute__((objc_direct));
- (void)exportOperationFinished:(CKOperationID)operationID savedRecords:(NSArray<CKRecord *> * _Nullable)savedRecords deletedRecordIDs:(NSArray<CKRecordID *> * _Nullable)deletedRecordIDs operationError:(NSError * _Nullable)operationError __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
