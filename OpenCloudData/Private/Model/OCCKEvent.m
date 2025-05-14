//
//  OCCKEvent.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 3/30/25.
//

#import <OpenCloudData/OCCKEvent.h>
#import <OpenCloudData/OCCloudKitMetadataModel.h>
#import <objc/runtime.h>

@implementation OCCKEvent
@dynamic entityPath;
@dynamic eventIdentifier;
@dynamic cloudKitEventType;
@dynamic startedAt;
@dynamic endedAt;
@dynamic succeeded;
@dynamic errorDomain;
@dynamic errorCode;
@dynamic countAffectedObjects;
@dynamic countFinishedObjects;

+ (NSString *)entityPath {
//    return [NSString stringWithFormat:@"%@/%@", [OCCloudKitMetadataModel ancillaryModelNamespace], NSStringFromClass(self)];
    return [NSString stringWithFormat:@"%@/%@", [OCCloudKitMetadataModel ancillaryModelNamespace], NSStringFromClass(objc_lookUpClass("NSCKEvent"))];
}

+ (OCPersistentCloudKitContainerEvent *)beginEventForRequest:(OCCloudKitMirroringRequest *)request withMonitor:(OCCloudKitStoreMonitor *)monitor error:(NSError * _Nullable *)error {
    abort();
}

@end
