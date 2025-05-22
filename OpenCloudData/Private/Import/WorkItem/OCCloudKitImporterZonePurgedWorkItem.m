//
//  OCCloudKitImporterZonePurgedWorkItem.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/16/25.
//

#import "OpenCloudData/Private/Import/WorkItem/OCCloudKitImporterZonePurgedWorkItem.h"
#import "OpenCloudData/Private/OCCloudKitMirroringDelegate.h"
#import "OpenCloudData/SPI/CoreData/NSPersistentStore+Private.h"
#import "OpenCloudData/SPI/OCSPIResolver.h"

@implementation OCCloudKitImporterZonePurgedWorkItem

- (instancetype)initWithPurgedRecordZoneID:(CKRecordZoneID *)recordZoneID options:(OCCloudKitImporterOptions *)options request:(OCCloudKitMirroringImportRequest *)request {
    // recordZoneID = x19
    if (self = [super initWithOptions:options request:request]) {
        _purgedRecordZoneID = [recordZoneID retain];
    }
    
    return self;
}

- (void)dealloc {
    [_purgedRecordZoneID release];
    [super dealloc];
}

- (NSString *)description {
    // self = x19
    NSMutableString *result = [[NSMutableString alloc] initWithFormat:@"<%@: %p - %@>", NSStringFromClass([self class]), self, self.request];
    [result appendFormat:@" { %@ }", self->_purgedRecordZoneID];
    return [result autorelease];
}

- (void)doWorkForStore:(NSSQLCore *)store inMonitor:(OCCloudKitStoreMonitor *)monitor completion:(void (^)(OCCloudKitMirroringResult * _Nonnull))completion {
    /*
     self = x22
     store = x21
     monitor = x23
     completion = x19
     */
    // sp, #0x8
    NSError * _Nullable error = nil;
    // x20
    OCCloudKitMirroringDelegate *mirroringDelegate = (OCCloudKitMirroringDelegate *)[store.mirroringDelegate retain];
    // x23
    NSNotification *notification = [[NSNotification alloc] initWithName:[OCSPIResolver NSCloudKitMirroringDelegateWillResetSyncNotificationName] object:mirroringDelegate userInfo:@{
        [OCSPIResolver NSCloudKitMirroringDelegateResetSyncReasonKey]: @4
    }];
    [mirroringDelegate logResetSyncNotification:notification];
    [NSNotificationCenter.defaultCenter postNotification:notification];
    [notification release];
    
    // <+220>
    // x24
    OCCloudKitMetadataPurger *metadataPurger = self.options.options.metadataPurger;
    
    BOOL result = [metadataPurger purgeMetadataFromStore:store inMonitor:monitor withOptions:9 forRecordZones:@[self->_purgedRecordZoneID] inDatabaseWithScope:self.options.options.databaseScope andTransactionAuthor:[OCSPIResolver NSCloudKitMirroringDelegateResetSyncAuthor] error:&error];
    
    // x21
    OCCloudKitMirroringResult *mirroringResult;
    if (result) {
        // <+348>
        // x23
        NSNotification *notification = [[NSNotification alloc] initWithName:[OCSPIResolver NSCloudKitMirroringDelegateDidResetSyncNotificationName] object:mirroringDelegate userInfo:@{
            [OCSPIResolver NSCloudKitMirroringDelegateResetSyncReasonKey]: @4
        }];
        [mirroringDelegate logResetSyncNotification:notification];
        [notification release];
        
        mirroringResult = [[OCCloudKitMirroringResult alloc] initWithRequest:self.request storeIdentifier:store.identifier success:YES madeChanges:YES error:nil];
    } else {
        // <+520>
        mirroringResult = [[OCCloudKitMirroringResult alloc] initWithRequest:self.request storeIdentifier:store.identifier success:NO madeChanges:NO error:error];
    }
    
    if (completion != nil) {
        completion(mirroringResult);
    }
    
    [mirroringDelegate release];
    [mirroringResult release];
}

@end
