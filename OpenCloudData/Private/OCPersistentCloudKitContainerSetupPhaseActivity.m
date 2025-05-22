//
//  OCPersistentCloudKitContainerSetupPhaseActivity.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 3/31/25.
//

#import "OpenCloudData/Private/OCPersistentCloudKitContainerSetupPhaseActivity.h"
#import "OpenCloudData/Private/Log.h"

@interface OCPersistentCloudKitContainerSetupPhaseActivity () {
    NSUInteger _phase;
}
@end

@implementation OCPersistentCloudKitContainerSetupPhaseActivity

+ (NSString *)stringForPhase:(NSUInteger)phase {
    switch (phase) {
        case 0:
            return @"setup-phase";
        case 1:
            return @"initialize-metadata";
        case 2:
            return @"check-account";
        case 3:
            return @"check-user-identity";
        case 4:
            return @"initialize-zone";
        case 5:
            return @"initialize-database-subscription";
        case 6:
            return @"initialize-asset-storage";
        default:
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: I don't know how to create a string for this phase: %lu", phase);
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: I don't know how to create a string for this phase: %lu", phase);
            abort();
    }
}

- (instancetype)initWithPhase:(NSUInteger)phase storeIdentifier:(NSString *)storeIdentifier {
    if (self = [super _initWithIdentifier:[NSUUID UUID] forStore:storeIdentifier activityType:4]) {
        _phase = phase;
    }
    
    return self;
}

- (NSMutableDictionary *)createDictionaryRepresentation {
    NSMutableDictionary *result = [super createDictionaryRepresentation];
    NSString *phaseString = [OCPersistentCloudKitContainerSetupPhaseActivity stringForPhase:_phase];
    result[@"phase"] = phaseString;
    return result;
}

@end
