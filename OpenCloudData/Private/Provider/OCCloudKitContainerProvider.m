//
//  OCCloudKitContainerProvider.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/22/25.
//

#import <OpenCloudData/OCCloudKitContainerProvider.h>
#import <OpenCloudData/CKContainer+Private.h>

@implementation OCCloudKitContainerProvider

- (CKContainer *)containerWithIdentifier:(NSString *)identifier {
    // original : getCloudKitCKContainerClass
    return [CKContainer containerWithIdentifier:identifier];
}

- (CKContainer *)containerWithIdentifier:(NSString *)identifier options:(CKContainerOptions *)options {
    CKContainer *container = [CKContainer containerWithIdentifier:identifier];
    if (container == nil) return nil;
    if (options == nil) return container;
    
    // original : getCloudKitCKContainerClass
    return [[[CKContainer alloc] initWithContainerID:container.containerID options:options] autorelease];
}

@end
