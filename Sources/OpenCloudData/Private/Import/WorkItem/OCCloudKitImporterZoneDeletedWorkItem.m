//
//  OCCloudKitImporterZoneDeletedWorkItem.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/16/25.
//

#import "OpenCloudData/Private/Import/WorkItem/OCCloudKitImporterZoneDeletedWorkItem.h"
#import "OpenCloudData/Private/OCCloudKitMetadataPurger.h"

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
    [OCCloudKitMetadataPurger purgeMetadataFromStore:store inMonitor:monitor withOptions:0];
    abort();
}

@end
