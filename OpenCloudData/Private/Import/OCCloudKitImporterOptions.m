//
//  OCCloudKitImporterOptions.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/14/25.
//

#import <OpenCloudData/OCCloudKitImporterOptions.h>

@implementation OCCloudKitImporterOptions

- (instancetype)initWithOptions:(OCCloudKitMirroringDelegateOptions *)options monitor:(OCCloudKitStoreMonitor *)monitor assetStorageURL:(NSURL *)assetStorageURL workQueue:(dispatch_queue_t)workQueue andDatabase:(CKDatabase *)database {
    /*
     options = x24
     monitor = x22
     assetStorageURL = x19
     workQueue = x20
     database = x23
     */
    if (self = [super init]) {
        _options = [options copy];
        _database = [database retain];
        _monitor = [monitor retain];
        _assetStorageURL = [assetStorageURL retain];
        _workQueue = workQueue;
        if (_workQueue != nil) {
            dispatch_retain(_workQueue);
        }
    }
    
    return self;
}

- (void)dealloc {
    [_database release];
    [_monitor release];
    [_options release];
    if (_workQueue != nil) {
        dispatch_release(_workQueue);
    }
    [_assetStorageURL release];
    [super dealloc];
}

- (id)copy {
    return [[OCCloudKitImporterOptions alloc] initWithOptions:_options monitor:_monitor assetStorageURL:_assetStorageURL workQueue:_workQueue andDatabase:_database];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    return [self copy];
}

@end
