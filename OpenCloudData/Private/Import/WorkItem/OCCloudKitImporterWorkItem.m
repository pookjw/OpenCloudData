//
//  OCCloudKitImporterWorkItem.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/15/25.
//

#import "OpenCloudData/Private/Import/WorkItem/OCCloudKitImporterWorkItem.h"

FOUNDATION_EXTERN void NSRequestConcreteImplementation(id self, SEL _cmd, Class absClass);

@implementation OCCloudKitImporterWorkItem

- (instancetype)initWithOptions:(OCCloudKitImporterOptions *)options request:(OCCloudKitMirroringImportRequest *)request {
    /*
     options = x20
     request = x19
     */
    if (self = [super init]) {
        // self = x21
        _options = [options retain];
        _request = [request retain];
    }
    
    return self;
}

- (void)dealloc {
    [_options release];
    _options = nil;
    
    [_request release];
    _request = nil;
    
    [super dealloc];
}

- (void)doWorkForStore:(NSSQLCore *)store inMonitor:(OCCloudKitStoreMonitor *)monitor completion:(void (^)(OCCloudKitMirroringResult * _Nonnull))completion {
    NSRequestConcreteImplementation(self, _cmd, [OCCloudKitImporterWorkItem class]);
}

@end
