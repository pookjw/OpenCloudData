//
//  NSPersistentStore+OpenCloudData_Private.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import "OpenCloudData/Private/NSPersistentStore+OpenCloudData_Private.h"
#import "OpenCloudData/SPI/CoreData/NSPersistentStore+Private.h"
#import "OpenCloudData/Private/OCCloudKitMirroringDelegate.h"

@implementation NSPersistentStore (OpenCloudData_Private)

- (BOOL)oc_isCloudKitEnabled {
    NSObject<NSPersistentStoreMirroringDelegate> * _Nullable mirroringDelegate = self.mirroringDelegate;
    if (mirroringDelegate == nil) {
        return NO;
    }
    
    return [mirroringDelegate isKindOfClass:[OCCloudKitMirroringDelegate class]];
}

@end
