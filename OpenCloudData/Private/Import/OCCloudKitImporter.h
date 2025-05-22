//
//  OCCloudKitImporter.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/14/25.
//

#import "OpenCloudData/Private/Import/OCCloudKitImporterOptions.h"
#import "OpenCloudData/Private/Request/OCCloudKitMirroringRequest.h"
#import "OpenCloudData/Private/Request/OCCloudKitMirroringImportRequest.h"
#import "OpenCloudData/Private/OCCloudKitMirroringResult.h"
#import "OpenCloudData/Private/Import/WorkItem/OCCloudKitImporterWorkItem.h"
#import "OpenCloudData/Private/Import/OCCloudKitImportDatabaseContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitImporter : NSObject {
    OCCloudKitImporterOptions *_options; // 0x8
    OCCloudKitMirroringImportRequest *_request; // 0x10
    // assign인듯
    NSArray<OCCloudKitImporterWorkItem *> *_workItems; // 0x18
    NSMutableArray<OCCloudKitMirroringResult *> *_workItemResults; // 0x20
    CKServerChangeToken *_updatedDatabaseChangeToken; // 0x28
    size_t _totalImportedBytes; // 0x30
}
- (instancetype)initWithOptions:(OCCloudKitImporterOptions *)options request:(OCCloudKitMirroringImportRequest *)request;
- (void)importIfNecessaryWithCompletion:(void (^ _Nullable)(OCCloudKitMirroringResult *result))completion __attribute__((objc_direct));
- (void)processWorkItemsWithCompletion:(void (^ _Nullable)(OCCloudKitMirroringResult *result))completion __attribute__((objc_direct));
- (void)workItemFinished:(OCCloudKitImporterWorkItem *)workItem withResult:(OCCloudKitMirroringResult *)result completion:(void (^ _Nullable)(OCCloudKitMirroringResult *result))completion __attribute__((objc_direct));
- (void)databaseFetchFinishWithContext:(OCCloudKitImportDatabaseContext *)context error:(NSError * _Nullable)error completion:(void (^ _Nullable)(OCCloudKitMirroringResult *result))completion __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
