//
//  OCCloudKitSizeMetric.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/20/25.
//

#import "OpenCloudData/Private/Metric/OCCloudKitSizeMetric.h"

@implementation OCCloudKitSizeMetric

- (instancetype)initWithContainerIdentifier:(NSString *)containerIdentifier {
    if (self = [super initWithContainerIdentifier:containerIdentifier]) {
        _sizeInBytes = [[NSNumber alloc] initWithInt:0];
    }
    
    return self;
}

- (void)dealloc {
    [_sizeInBytes release];
    [super dealloc];
}

- (NSDictionary<NSString *,id> *)payload {
    NSMutableDictionary<NSString *, id> *result = [[super payload] mutableCopy];
    
    if (_sizeInBytes == nil) {
        result[@"sizeInBytes"] = [NSNull null];
    } else {
        result[@"sizeInBytes"] = _sizeInBytes;
    }
    
    return [result autorelease];
}

- (void)addByteSize:(size_t)byteSize {
    size_t result = _sizeInBytes.unsignedIntegerValue;
    [_sizeInBytes release];
    _sizeInBytes = [[NSNumber alloc] initWithUnsignedInteger:result + byteSize];
}

@end
