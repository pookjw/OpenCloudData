//
//  OCCloudKitImporterZoneChangedWorkItem.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/15/25.
//

#import <OpenCloudData/OCCloudKitImporterZoneChangedWorkItem.h>

@implementation OCCloudKitImporterZoneChangedWorkItem

- (instancetype)initWithChangedRecordZoneIDs:(NSArray<CKRecordZoneID *> *)recordZoneIDs options:(OCCloudKitImporterOptions *)options request:(OCCloudKitMirroringImportRequest *)request {
    /*
     recordZoneIDs = x20
     */
    if (self = [super initWithOptions:options request:request]) {
        // self = x19
        self->_changedRecordZoneIDs = [recordZoneIDs retain];
        self->_fetchedZoneIDToChangeToken = [[NSMutableDictionary alloc] init];
        self->_fetchedZoneIDToMoreComing = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [_changedRecordZoneIDs release];
    [_fetchedZoneIDToChangeToken release];
    [_fetchedZoneIDToMoreComing release];
    [super dealloc];
}

- (NSString *)description {
    // self = x19
    // x20
    NSMutableString *result = [[NSMutableString alloc] initWithFormat:@"<%@: %p - %@>", NSStringFromClass([self class]), self, self.request];
    [result appendFormat:@" {\n%@\n}", self->_changedRecordZoneIDs];
    return [result autorelease];
}

- (BOOL)commitMetadataChangesWithContext:(NSManagedObjectContext *)managedObjectContext forStore:(NSSQLCore *)store error:(NSError * _Nullable *)error {
    /*
     self = x23
     managedObjectContext = x22
     store = x21
     error = sp
     */
    abort();
}

@end
