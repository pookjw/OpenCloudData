//
//  OCPersistentCloudKitContainerActivityVoucher.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import "OpenCloudData/Private/OCPersistentCloudKitContainerActivityVoucher.h"
#import "OpenCloudData/Public/OCPersistentCloudKitContainerEvent.h"
#import "OpenCloudData/Private/Log.h"
#import "OpenCloudData/SPI/CloudKit/CKOperationConfiguration+Private.h"

@implementation OCPersistentCloudKitContainerActivityVoucher

+ (BOOL)supportsSecureCoding {
    return YES;
}

+ (NSString *)describeConfiguration:(CKOperationConfiguration *)configuration {
    if (configuration == nil) {
        return @"nil";
    }
    // configuration = x19
    
    return [NSString stringWithFormat:@"<%@:%p %@:%@:%d:%f:%f>", NSStringFromClass([configuration class]), configuration, [OCPersistentCloudKitContainerActivityVoucher stringForQoS:configuration.qualityOfService], (configuration.allowsCellularAccess ? @"wifi+celluar" : @"wifi-only"), configuration.longLived, configuration.timeoutIntervalForRequest, configuration.timeoutIntervalForResource];
}

+ (NSString *)describeConfigurationWithoutPointer:(CKOperationConfiguration *)configuration {
    if (configuration == nil) {
        return @"nil";
    }
    // configuration = x19
    
    return [NSString stringWithFormat:@"%@:%@:%d:%f:%f", [OCPersistentCloudKitContainerActivityVoucher stringForQoS:configuration.qualityOfService], (configuration.allowsCellularAccess ? @"wifi+celluar" : @"wifi-only"), configuration.longLived, configuration.timeoutIntervalForRequest, configuration.timeoutIntervalForResource];
}

+ (NSString *)stringForQoS:(NSQualityOfService)qualityOfService {
    switch (qualityOfService) {
        case NSQualityOfServiceUtility:
            return @"Utility";
        case NSQualityOfServiceUserInteractive:
            return @"UserInteractive";
        case NSQualityOfServiceUserInitiated:
            return @"UserInitiated";
        case NSQualityOfServiceDefault:
            return @"Default";
        case NSQualityOfServiceBackground:
            return @"Background";
        default:
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Did someone add a new QoS class? This method should probably be updated.\n");
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Did someone add a new QoS class? This method should probably be updated.\n");
            return @"unknown";
    }
}

- (instancetype)initWithLabel:(NSString *)label forEventsOfType:(NSInteger)eventType withConfiguration:(CKOperationConfiguration *)configuration affectingObjectsMatching:(NSFetchRequest *)fetchRequest {
    /*
     label = x22
     eventType = x23
     configuration = x19
     fetchRequest = x20
     */
    if (self = [super init]) {
        // self = x21
        if (eventType == 0) {
            // <+288>
            // original : NSPersistentCloudKitContainerActivityVoucher
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%@ does not support the escalation of events of type %@. %@ events will be escalated in association with a voucher that is applied to %@ / %@ events as needed.", NSStringFromClass([OCPersistentCloudKitContainerActivityVoucher class]), [OCPersistentCloudKitContainerEvent eventTypeString:0], [OCPersistentCloudKitContainerEvent eventTypeString:0], [OCPersistentCloudKitContainerEvent eventTypeString:2], [OCPersistentCloudKitContainerEvent eventTypeString:1]] userInfo:nil];
        }
        
        if (configuration == nil) {
            // <+424>
            // original : NSPersistentCloudKitContainerActivityVoucher, getCloudKitCKOperationConfigurationClass
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%@ requires that clients pass in an instance of %@ that describes how they would like to prioritize work on behalf of the voucher.", NSStringFromClass([OCPersistentCloudKitContainerActivityVoucher class]), NSStringFromClass([CKOperationConfiguration class])] userInfo:nil];
        }
        
        if (configuration.longLived) {
            // <+512>
            // original : NSPersistentCloudKitContainerActivityVoucher, NSPersistentCloudKitContainerEvent
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%@ does not allow clients to specify if operations are longlived or not. Clients should leave longLived unmodified and allow %@ to choose to mark operations long lived or not.", NSStringFromClass([OCPersistentCloudKitContainerActivityVoucher class]), NSStringFromClass([OCPersistentCloudKitContainerEvent class])] userInfo:nil];
        }
        
        if (!configuration.allowsCellularAccess) {
            // <+656>
            // original : NSPersistentCloudKitContainerActivityVoucher
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%@ does not support network customizations yet (allowsCellularAccess = NO). If you require this functionality please file a radar to CoreData | New Bugs.", NSStringFromClass([OCPersistentCloudKitContainerActivityVoucher class])] userInfo:nil];
        }
        
        if (!configuration.allowsExpensiveNetworkAccess) {
            // <+716>
            // original : NSPersistentCloudKitContainerActivityVoucher
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%@ does not support network customizations yet (allowsExpensiveNetworkAccess = NO). If you require this functionality please file a radar to CoreData | New Bugs.", NSStringFromClass([OCPersistentCloudKitContainerActivityVoucher class])] userInfo:nil];
        }
        
        // <+140>
        
        _eventType = eventType;
        _bundleIdentifier = [NSBundle.mainBundle.bundleIdentifier retain];
        _processName = [NSProcessInfo.processInfo.processName retain];
        _label = [label copy];
        _fetchRequest = [fetchRequest copy];
        _operationConfiguration = [configuration copy];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        _label = [[coder decodeObjectOfClass:[NSString class] forKey:@"label"] retain];
        _bundleIdentifier = [[coder decodeObjectOfClass:[NSString class] forKey:@"bundleIdentifier"] retain];
        _eventType = ((NSNumber *)[coder decodeObjectOfClass:[NSNumber class] forKey:@"eventTypeNum"]).unsignedIntegerValue;
        _fetchRequest = [[coder decodeObjectOfClass:[NSFetchRequest class] forKey:@"fetchRequest"] retain];
        _operationConfiguration = [[coder decodeObjectOfClass:[CKOperationConfiguration class] forKey:@"operationConfiguration"] retain];
    }
    
    return self;
}

- (void)dealloc {
    [_processName release];
    [_bundleIdentifier release];
    _bundleIdentifier = nil;
    [_label release];
    [_fetchRequest release];
    _fetchRequest = nil;
    [_operationConfiguration release];
    _operationConfiguration = nil;
    [super dealloc];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    OCPersistentCloudKitContainerActivityVoucher *copy = [[OCPersistentCloudKitContainerActivityVoucher alloc] initWithLabel:_label forEventsOfType:_eventType withConfiguration:_operationConfiguration affectingObjectsMatching:_fetchRequest];
    [copy->_bundleIdentifier release];
    copy->_bundleIdentifier = [_bundleIdentifier retain];
    return copy;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:@(_eventType) forKey:@"eventTypeNum"];
    [coder encodeObject:_label forKey:@"label"];
    [coder encodeObject:_bundleIdentifier forKey:@"bundleIdentifier"];
    [coder encodeObject:_fetchRequest forKey:@"fetchRequest"];
    [coder encodeObject:_operationConfiguration forKey:@"operationConfiguration"];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:%p %@>\n\t%@\n\t%@:%@\n\t%@\n\t%@", NSStringFromClass([self class]), self, _label, [OCPersistentCloudKitContainerEvent eventTypeString:_eventType], _processName, _bundleIdentifier, [OCPersistentCloudKitContainerActivityVoucher describeConfiguration:_operationConfiguration], _fetchRequest];
}

@end
