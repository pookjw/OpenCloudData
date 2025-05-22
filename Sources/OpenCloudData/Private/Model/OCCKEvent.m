//
//  OCCKEvent.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 3/30/25.
//

#import "OpenCloudData/Private/Model/OCCKEvent.h"
#import "OpenCloudData/Private/OCCloudKitMetadataModel.h"
#import "OpenCloudData/SPI/OCSPIResolver.h"
#import "OpenCloudData/Private/Request/OCCloudKitMirroringDelegateSetupRequest.h"
#import "OpenCloudData/Private/Request/OCCloudKitMirroringImportRequest.h"
#import "OpenCloudData/Private/Request/OCCloudKitMirroringExportRequest.h"
#import "OpenCloudData/Public/OCPersistentCloudKitContainerEvent.h"
#import "OpenCloudData/Private/Log.h"
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
    /*
     request = x21
     monitor = x20
     error = x19
     */
    
    // sp, #0x70
    __block OCPersistentCloudKitContainerEvent * _Nullable result = nil;
    // sp, #0x40
    __block NSError * _Nullable _error = nil;
    
    /*
     __52+[NSCKEvent beginEventForRequest:withMonitor:error:]_block_invoke
     monitor = sp + 0x20 = x20 + 0x20
     request = sp + 0x28 = x20 + 0x28
     result = sp + 0x30 = x20 + 0x30
     _error = sp + 0x38 = x20 + 0x38
     */
    [monitor performBlock:^{
        // self(block) = x20
        // x19
        NSSQLCore * _Nullable store = [monitor retainedMonitoredStore];
        if (store == nil) {
            // <+172>
            _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134407 userInfo:@{
                NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat: @"Request '%@' was cancelled because the store was removed from the coordinator.", request.requestIdentifier]
            }];
            return;
        }
        // x21
        NSManagedObjectContext *managedObjectContext = [monitor newBackgroundContextForMonitoredCoordinator];
        managedObjectContext.transactionAuthor = [OCSPIResolver NSCloudKitMirroringDelegateEventAuthor];
        
        /*
         __52+[NSCKEvent beginEventForRequest:withMonitor:error:]_block_invoke_2
         managedObjectContext = sp + 0x30 = x19 + 0x20
         request = sp + 0x38 = x19 + 0x28
         store = sp + 0x40 = x19 + 0x30
         result = sp + 0x48 = x19 + 0x38
         _error = sp + 0x50 = x19 + 0x40
         */
        [managedObjectContext performBlockAndWait:^{
            // self(block) = x19
            // sp, #0x8
            NSError * _Nullable __error = nil;
            // x20
            OCCKEvent *newEvent = [NSEntityDescription insertNewObjectForEntityForName:OCCKEvent.entityPath inManagedObjectContext:managedObjectContext];
            newEvent.eventIdentifier = request.requestIdentifier;
            
            if ([request isKindOfClass:[OCCloudKitMirroringDelegateSetupRequest class]]) {
                newEvent.cloudKitEventType = 0;
            } else if ([result isKindOfClass:[OCCloudKitMirroringImportRequest class]]) {
                newEvent.cloudKitEventType = 1;
            } else if ([result isKindOfClass:[OCCloudKitMirroringExportRequest class]]) {
                newEvent.cloudKitEventType = 2;
            } else {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Cannot create persistent event for request: %@\n", request);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Cannot create persistent event for request: %@\n", request);
                newEvent.cloudKitEventType = 0;
            }
            
            newEvent.startedAt = [NSDate date];
            [managedObjectContext assignObject:newEvent toPersistentStore:store];
            
            BOOL _result = [managedObjectContext save:&__error];
            if (!_result) {
                _error = [__error retain];
                return;
            }
            
            result = [[OCPersistentCloudKitContainerEvent alloc] initWithCKEvent:newEvent];
        }];
        
        [managedObjectContext release];
        [store release];
    }];
    
    if (result == nil) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d", __FILE__, __LINE__);
        } else {
            if (error != NULL) {
                *error = [[_error retain] autorelease];
            }
        }
    }
    
    [_error release];
    return result;
}

@end
