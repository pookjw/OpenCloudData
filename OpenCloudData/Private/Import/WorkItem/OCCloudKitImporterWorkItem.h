//
//  OCCloudKitImporterWorkItem.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/15/25.
//

#import <OpenCloudData/OCCloudKitImporterOptions.h>
#import <OpenCloudData/OCCloudKitMirroringImportRequest.h>
#import <OpenCloudData/OCCloudKitStoreMonitor.h>
#import <OpenCloudData/OCCloudKitMirroringResult.h>
#import <OpenCloudData/NSSQLCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitImporterWorkItem : NSObject {
    OCCloudKitImporterOptions *_options; // 0x8
    OCCloudKitMirroringImportRequest *_request; // 0x10
}
@property (retain, nonatomic, readonly, direct) OCCloudKitImporterOptions *options;
@property (retain, nonatomic, readonly, direct) OCCloudKitMirroringImportRequest *request;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithOptions:(OCCloudKitImporterOptions *)options request:(OCCloudKitMirroringImportRequest *)request;
- (void)doWorkForStore:(NSSQLCore *)store inMonitor:(OCCloudKitStoreMonitor *)monitor completion:(void (^ _Nullable)(OCCloudKitMirroringResult *result))completion;
@end

NS_ASSUME_NONNULL_END
