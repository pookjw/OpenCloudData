//
//  OCPersistentCloudKitContainerActivity.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 3/31/25.
//

#import "OpenCloudData/Private/OCPersistentCloudKitContainerActivity.h"
#import "OpenCloudData/Private/Log.h"

@implementation OCPersistentCloudKitContainerActivity

- (instancetype)_initWithIdentifier:(NSUUID *)identifier forStore:(NSString *)storeIdentifier activityType:(NSUInteger)activityType {
    if (self = [super init]) {
        _identifier = [identifier retain];
        _storeIdentifier = [storeIdentifier retain];
        
        NSDate *date = [[NSDate alloc] init];
        _activityType = activityType;
        _startDate = date;
    }
    
    return self;
}

- (NSDictionary *)createDictionaryRepresentation {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    dictionary[@"identifier"] = _identifier;
    dictionary[@"storeIdentifier"] = _storeIdentifier;
    
    NSUUID *parentActivityIdentifier = _parentActivityIdentifier;
    if (parentActivityIdentifier != nil) {
        dictionary[@"parentActivityIdentifier"] = parentActivityIdentifier;
    }
    
    NSUInteger activityType = _activityType;
    NSString *activityTypeString;
    switch (_activityType) {
        case 0:
            activityTypeString = @"event";
            break;
        case 1:
            activityTypeString = @"cloudkit-operation";
            break;
        case 2:
            activityTypeString = @"history-analysis";
            break;
        case 3:
            activityTypeString = @"record-serialization";
            break;
        case 4:
            activityTypeString = @"setup-phase";
            break;
        default:
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: I don't know how to create a string for activity type '%lu'", activityType);
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: I don't know how to create a string for activity type '%lu'", activityType);
            abort();
    }
    dictionary[@"activityType"] = activityTypeString;
    
    dictionary[@"startDate"] = _startDate;
    
    NSDate *endDate = _endDate;
    if (endDate != nil) {
        dictionary[@"endDate"] = endDate;
    }
    
    NSError *error = _error;
    if (error != nil) {
        dictionary[@"error"] = error;
    }
    
    BOOL succeeded;
    if (_endDate == nil) {
        succeeded = NO;
    } else {
        succeeded = (_error == nil);
    }
    dictionary[@"succeeded"] = @(succeeded);
    
    dictionary[@"finished"] = @(_endDate != nil);
    
    return dictionary;
}

- (void)finishWithError:(NSError *)error {
    if (_endDate != nil) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to finish an activity multiple times: %@\\n", self);
        abort();
    }
    
    _endDate = [[NSDate alloc] init];
    _error = [error retain];
}

@end
