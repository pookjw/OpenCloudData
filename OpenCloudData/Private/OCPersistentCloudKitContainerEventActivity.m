//
//  OCPersistentCloudKitContainerEventActivity.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 3/31/25.
//

#import <OpenCloudData/OCPersistentCloudKitContainerEventActivity.h>
#import <OpenCloudData/Log.h>
#import <OpenCloudData/OCPersistentCloudKitContainer.h>

@interface OCPersistentCloudKitContainerEventActivity () {
    NSMutableDictionary<NSNumber *, __kindof OCPersistentCloudKitContainerActivity *> *_activitiesByPhaseNum;
    NSInteger _eventType;
}
@end

@implementation OCPersistentCloudKitContainerEventActivity

- (instancetype)initWithRequestIdentifier:(NSUUID *)requestIdentifier storeIdentifier:(NSString *)storeIdentifier eventType:(NSInteger)eventType {
    if (self = [super _initWithIdentifier:requestIdentifier forStore:storeIdentifier activityType:0]) {
        _activitiesByPhaseNum = [[NSMutableDictionary alloc] init];
        _eventType = eventType;
    }
    
    return self;
}

- (void)dealloc {
    [_activitiesByPhaseNum release];
    [super dealloc];
}

- (__kindof OCPersistentCloudKitContainerActivity *)beginActivityForPhase:(NSUInteger)phase {
    OCPersistentCloudKitContainerSetupPhaseActivity *activity = [OCPersistentCloudKitContainerSetupPhaseActivity alloc];
    
    if (self) {
        [activity initWithPhase:phase storeIdentifier:_storeIdentifier];
    } else {
        [activity initWithPhase:phase storeIdentifier:nil];
    }
    
    NSUUID *identifier = _identifier;
    if (identifier != nil) {
        NSUUID *parentActivityIdentifier = activity->_parentActivityIdentifier;
        
        if (identifier != parentActivityIdentifier) {
            [parentActivityIdentifier release];
            activity->_parentActivityIdentifier = [identifier retain];
        }
    }
    
    _activitiesByPhaseNum[@(phase)] = activity;
    
    return activity;
}

- (__kindof OCPersistentCloudKitContainerActivity *)endActivityForPhase:(NSUInteger)phase withError:(NSError *)error {
    __kindof OCPersistentCloudKitContainerActivity *activity = [_activitiesByPhaseNum[@(phase)] retain];
    
    if (activity == nil) {
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: No activity was found for phase '%@', this is a critical bug in activity tracking for %@. Please file a radar.", [OCPersistentCloudKitContainerSetupPhaseActivity stringForPhase:phase], NSStringFromClass([OCPersistentCloudKitContainer class]));
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: No activity was found for phase '%@', this is a critical bug in activity tracking for %@. Please file a radar.", [OCPersistentCloudKitContainerSetupPhaseActivity stringForPhase:phase], NSStringFromClass([OCPersistentCloudKitContainer class]));
    }
    
    [activity finishWithError:error];
    return activity;
}

- (NSMutableDictionary *)createDictionaryRepresentation {
    NSMutableDictionary *result = [super createDictionaryRepresentation];
    result[@"eventType"] = @(_eventType);
    return result;
}

@end
