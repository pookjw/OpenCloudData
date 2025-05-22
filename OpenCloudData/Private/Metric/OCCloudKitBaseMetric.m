//
//  OCCloudKitBaseMetric.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/20/25.
//

#import "OpenCloudData/Private/Metric/OCCloudKitBaseMetric.h"
#import "OpenCloudData/Private/Log.h"

@implementation OCCloudKitBaseMetric

- (instancetype)initWithContainerIdentifier:(NSString *)containerIdentifier {
    if (self = [super init]) {
        _containerIdentifier = [containerIdentifier retain];
        _processName = [NSProcessInfo.processInfo.processName retain];
    }
    
    return self;
}

- (void)dealloc {
    [_containerIdentifier release];
    [_processName release];
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@\n%@", [super description], self.name, self.payload];
}

- (NSString *)name {
    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Attempt to log metric with OCCloudKitBaseMetric, but each subclass must provide it's own name.\n");
    os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Attempt to log metric with OCCloudKitBaseMetric, but each subclass must provide it's own name.\n");
    
#warning TODO 바꿔도 되나?
    return @"com.apple.coredata.cloudkit.base";
}

- (NSDictionary<NSString *,id> *)payload {
    return @{
        @"processName": (_processName == nil) ? [NSNull null] : _processName,
        @"containerIdentifier": (_containerIdentifier == nil) ? [NSNull null] : _containerIdentifier
    };
}

@end
