//
//  OCCloudKitImporter.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/14/25.
//

#import <OpenCloudData/OCCloudKitImporterOptions.h>
#import <OpenCloudData/OCCloudKitMirroringRequest.h>
#import <OpenCloudData/OCCloudKitMirroringImportRequest.h>
#import <OpenCloudData/OCCloudKitMirroringResult.h>
#import <OpenCloudData/OCCloudKitImporterWorkItem.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

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
- (void)importIfNecessaryWithCompletion:(void (^)(OCCloudKitMirroringResult *result))completion __attribute__((objc_direct));
- (void)processWorkItemsWithCompletion:(void (^)(OCCloudKitMirroringResult *result))completion __attribute__((objc_direct));
- (void)workItemFinished:(OCCloudKitImporterWorkItem *)workItem withResult:(OCCloudKitMirroringResult *)result completion:(void (^)(OCCloudKitMirroringResult *result))completion __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
