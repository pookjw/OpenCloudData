//
//  OCPersistentCloudKitContainerEvent.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 3/30/25.
//

#import <OpenCloudData/OCPersistentCloudKitContainerEvent.h>
#import <OpenCloudData/Log.h>

@interface OCPersistentCloudKitContainerEvent () {
    NSManagedObjectID *_ckEventObjectID;
}
@end

@implementation OCPersistentCloudKitContainerEvent

+ (NSString *)eventTypeString:(NSInteger)type {
    switch (type) {
        case 0:
            return @"Setup";
        case 1:
            return @"Import";
        case 2:
            return @"Export";
        default:
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Unknown event type, cannot covert to string: %ld\n", type);
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Unknown event type, cannot covert to string: %ld\n", type);
            return nil;
    }
}

- (instancetype)initWithCKEvent:(OCCKEvent *)event {
    if (self = [super init]) {
        _ckEventObjectID = [event.objectID retain];
        _identifier = [event.eventIdentifier retain];
        _storeIdentifier = [event.objectID.persistentStore.identifier copy];
        _type = event.cloudKitEventType;
        _startDate = [event.startedAt retain];
        _endDate = [event.endedAt retain];
        _succeeded = event.succeeded;
        
        NSString * _Nullable errorDomain = event.errorDomain;
        if (errorDomain.length > 0) {
            _error = [[NSError alloc] initWithDomain:event.errorDomain code:event.errorCode userInfo:nil];
        }
    }
    
    return self;
}

- (void)dealloc {
    [_ckEventObjectID release];
    [_identifier release];
    [_storeIdentifier release];
    [_startDate release];
    [_endDate release];
    [_error release];
    [super dealloc];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    return [self retain];
}

- (BOOL)isEqual:(id)other {
    if (other == self) return YES;
    if (![other isKindOfClass:[self class]]) return NO;
    
    return [_identifier isEqual:((OCPersistentCloudKitContainerEvent *)other)->_identifier];
}

- (NSString *)description {
    NSMutableString *description = [[super description] mutableCopy];
    
    [description appendFormat:@" { type: %@ store: %@ started: %@ ended: %@", [OCPersistentCloudKitContainerEvent eventTypeString:_type], _storeIdentifier, _startDate, _error];
    [description appendFormat:@" succeeded: %@", _succeeded ? @"YES" : @"NO"];
    
    if (_error) {
        [description appendFormat:@" error: %@:%ld", _error.domain, _error.code];
    }
    
    [description appendString:@" }"];
    
    return [description autorelease];
}

@end
