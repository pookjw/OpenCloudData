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

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@class OCCloudKitExporter;
@protocol OCCloudKitExporterDelegate <NSObject>
- (void)exporter:(OCCloudKitExporter *)exporter willScheduleOperations:(NSArray<__kindof CKOperation *> *)operations;
@end

@interface OCCloudKitExporter : NSObject {
    NSMutableDictionary *_operationIDToResult;
#warning TODO
    id _exportCompletionBlock;
    OCCloudKitExporterOptions *_options;
    dispatch_queue_t _workQueue;
    __kindof OCCloudKitMirroringRequest *_request;
    __weak id<OCCloudKitExporterDelegate> delegate;
    OCCloudKitExportContext *_exportContext;
    OCCloudKitStoreMonitor *_monitor;
}
- (instancetype)initWithOptions:(OCCloudKitExporterOptions *)options request:(__kindof OCCloudKitMirroringRequest *)request monitor:(OCCloudKitStoreMonitor *)monitor workQueue:(dispatch_queue_t)workQueue;
@end

NS_ASSUME_NONNULL_END
