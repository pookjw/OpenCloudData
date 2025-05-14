//
//  OCCloudKitImporterOptions.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/14/25.
//

#import <OpenCloudData/OCCloudKitMirroringDelegateOptions.h>
#import <OpenCloudData/OCCloudKitStoreMonitor.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCCloudKitImporterOptions : NSObject <NSCopying>
- (instancetype)initWithOptions:(OCCloudKitMirroringDelegateOptions *)options monitor:(OCCloudKitStoreMonitor *)monitor assetStorageURL:(NSURL *)assetStorageURL workQueue:(dispatch_queue_t)workQueue andDatabase:(CKDatabase *)database;
@end

NS_ASSUME_NONNULL_END
