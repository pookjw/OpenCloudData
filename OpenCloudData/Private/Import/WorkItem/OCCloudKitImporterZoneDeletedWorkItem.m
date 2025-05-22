//
//  OCCloudKitImporterZoneDeletedWorkItem.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/16/25.
//

#import "OpenCloudData/Private/Import/WorkItem/OCCloudKitImporterZoneDeletedWorkItem.h"
#import "OpenCloudData/Private/OCCloudKitMetadataPurger.h"
#import "OpenCloudData/SPI/OCSPIResolver.h"

@implementation OCCloudKitImporterZoneDeletedWorkItem

- (instancetype)initWithDeletedRecordZoneID:(CKRecordZoneID *)recordZoneID options:(OCCloudKitImporterOptions *)options request:(OCCloudKitMirroringImportRequest *)request {
    // recordZoneID = x19
    if (self = [super initWithOptions:options request:request]) {
        // self = x20
        self->_deletedRecordZoneID = [recordZoneID retain];
    }
    
    return self;
}

- (void)dealloc {
    [_deletedRecordZoneID release];
    [super dealloc];
}

- (NSString *)description {
    // self = x19
    NSMutableString *result = [[NSMutableString alloc] initWithFormat:@"<%@: %p - %@>", NSStringFromClass([self class]), self, self.request];
    [result appendFormat:@" { %@ }", self->_deletedRecordZoneID];
    return [result autorelease];
}

- (void)doWorkForStore:(NSSQLCore *)store inMonitor:(OCCloudKitStoreMonitor *)monitor completion:(void (^)(OCCloudKitMirroringResult * _Nonnull))completion {
    /*
     self = x21
     store = x20
     monitor = x22
     completion = x19
     */
    // sp, #0x8
    NSError * _Nullable error = nil;
    // x23
    CKDatabaseScope databaseScope = self.options.options.databaseScope;
    // x23
    BOOL succees = [self.options.options.metadataPurger purgeMetadataFromStore:store inMonitor:monitor withOptions:(databaseScope == CKDatabaseScopeShared) ? 0x12b : 0x12a forRecordZones:@[self->_deletedRecordZoneID] inDatabaseWithScope:databaseScope andTransactionAuthor:[OCSPIResolver NSCloudKitMirroringDelegateImportContextName] error:&error];
    // x20
    OCCloudKitMirroringResult *result;
    if (succees) {
        result = [[OCCloudKitMirroringResult alloc] initWithRequest:self.request storeIdentifier:store.identifier success:NO madeChanges:YES error:nil];
    } else {
        result = [[OCCloudKitMirroringResult alloc] initWithRequest:self.request storeIdentifier:store.identifier success:NO madeChanges:NO error:error];
    }
    
    if (completion != nil) {
        completion(result);
    }
    
    [result release];
}

@end
