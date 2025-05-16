//
//  OCCloudKitImporterOptions.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/14/25.
//

#import <OpenCloudData/OCCloudKitMirroringDelegateOptions.h>
#import <OpenCloudData/OCCloudKitStoreMonitor.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitImporterOptions : NSObject <NSCopying> {
    @package CKDatabase *_database; // 0x8
    @package OCCloudKitStoreMonitor *_monitor; // 0x10
    OCCloudKitMirroringDelegateOptions *_options; // 0x18
    @package dispatch_queue_t _workQueue; // 0x20
    NSURL *_assetStorageURL; // 0x28
}
@property (retain, nonatomic, readonly, direct) OCCloudKitMirroringDelegateOptions *options;
- (instancetype)initWithOptions:(OCCloudKitMirroringDelegateOptions *)options monitor:(OCCloudKitStoreMonitor *)monitor assetStorageURL:(NSURL *)assetStorageURL workQueue:(dispatch_queue_t)workQueue andDatabase:(CKDatabase *)database;
@end

NS_ASSUME_NONNULL_END
