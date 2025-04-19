//
//  OCCloudKitExporter.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/4/25.
//

#import <CloudKit/CloudKit.h>
#import <OpenCloudData/OCCloudKitMirroringRequest.h>
#import <OpenCloudData/OCCloudKitExporterOptions.h>
#import <OpenCloudData/OCCloudKitStoreMonitor.h>
#import <OpenCloudData/OCCloudKitExportContext.h>
#import <OpenCloudData/OCCloudKitMirroringResult.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

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
- (void)exportIfNecessaryWithCompletion:(void (^)(OCCloudKitMirroringResult *result))completion __attribute__((objc_direct));
- (void)checkForZonesNeedingExport __attribute__((objc_direct));
- (void)finishExportWithResult:(OCCloudKitMirroringResult *)result __attribute__((objc_direct));
- (BOOL)updateMetadataForSavedZones:(NSArray<CKRecordZone *> *)savedZones error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
- (void)exportIfNecessary __attribute__((objc_direct));
- (void)fetchRecordZones:(NSArray<CKRecordZoneID *> *)zoneIDs __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
