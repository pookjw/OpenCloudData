//
//  NSPersistentStoreDescription+OpenCloudData.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import "OpenCloudData/Public/NSPersistentStoreDescription+OpenCloudData.h"
#import "OpenCloudData/Public/OCPersistentCloudKitContainerOptions.h"

@implementation NSPersistentStoreDescription (OpenCloudData)

- (OCPersistentCloudKitContainerOptions *)oc_cloudKitContainerOptions {
    return (OCPersistentCloudKitContainerOptions *)self.options[@"OCPersistentCloudKitContainerOptionsKey"];
}

- (void)oc_setCloudKitContainerOptions:(OCPersistentCloudKitContainerOptions *)cloudKitContainerOptions {
    [self setOption:cloudKitContainerOptions forKey:@"OCPersistentCloudKitContainerOptionsKey"];
}

@end
