//
//  OCStaticCloudKitContainerProvider.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/27/25.
//

#import "OpenCloudData/Private/Provider/OCStaticCloudKitContainerProvider.h"

@implementation OCStaticCloudKitContainerProvider

- (instancetype)initWithContainer:(CKContainer *)container {
    if (self = [super init]) {
        _container = [container retain];
    }
    
    return self;
}

- (void)dealloc {
    [_container release];
    [super dealloc];
}

- (CKContainer *)containerWithIdentifier:(NSString *)identifier {
    /*
     self = x20
     identifier = x19
     */
    
    if (![_container.containerIdentifier isEqualToString:identifier]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Invalid for a container '%@'. This object was configured to only respond to container requests for '%@'", identifier, _container.containerIdentifier] userInfo:nil];
    }
    
    return [[_container retain] autorelease];
}

- (CKContainer *)containerWithIdentifier:(NSString *)identifier options:(CKContainerOptions *)options {
    return [self containerWithIdentifier:identifier];
}

@end
