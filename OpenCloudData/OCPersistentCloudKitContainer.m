//
//  OCPersistentCloudKitContainer.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 3/30/25.
//

#import <OpenCloudData/OCPersistentCloudKitContainer.h>
#import <objc/runtime.h>
#import <objc/runtime.h>
#import <xpc/xpc.h>
#import <CoreFoundation/CoreFoundation.h>
#import <OpenCloudData/OCPersistentCloudKitContainer+Private.h>

XPC_EXPORT XPC_NONNULL_ALL XPC_WARN_RESULT XPC_RETURNS_RETAINED xpc_object_t xpc_copy_entitlement_for_self(const char *key);

CF_EXPORT CF_RETURNS_RETAINED CFTypeRef _CFXPCCreateCFObjectFromXPCObject(xpc_object_t object);

@implementation OCPersistentCloudKitContainer

+ (NSString *)discoverDefaultContainerIdentifier {
    xpc_object_t entitlements = xpc_copy_entitlement_for_self("com.apple.developer.icloud-container-identifiers");
    NSArray *array = (NSArray *)_CFXPCCreateCFObjectFromXPCObject(entitlements);
    
    NSString * _Nullable value;
    if (array.count == 0) {
        value = nil;
    } else {
        value = [[[array objectAtIndex:0] retain] autorelease];
    }
    
    [array release];
    xpc_release(entitlements);
    
    return value;
}

- (instancetype)initWithName:(NSString *)name managedObjectModel:(NSManagedObjectModel *)model {
    if (self = [super initWithName:name managedObjectModel:model]) {
        @autoreleasepool {
            NSString * _Nullable defaultContainerIdentifier = [OCPersistentCloudKitContainer discoverDefaultContainerIdentifier];
            NSLog(@"%@", defaultContainerIdentifier);
        }
    }
    
    return self;
}

@end
