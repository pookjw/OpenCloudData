//
//  OCCloudKitCKQueryBackedImportWorkItem.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/15/25.
//

#import <OpenCloudData/OCCloudKitCKQueryBackedImportWorkItem.h>
#import <OpenCloudData/OCCloudKitSerializer.h>
#import <OpenCloudData/OCCKRecordZoneMetadata.h>
#import <OpenCloudData/Log.h>

@implementation OCCloudKitCKQueryBackedImportWorkItem

- (instancetype)initForRecordType:(CKRecordType)recordType withOptions:(OCCloudKitImporterOptions *)options request:(OCCloudKitMirroringImportRequest *)request {
    /*
     recordType = x21
     options = x20
     */
    if (self = [super initWithOptions:options request:request]) {
        _recordType = [recordType retain];
        _zoneIDToQuery = [OCCloudKitSerializer defaultRecordZoneIDForDatabaseScope:options.options.databaseScope];
    }
    
    return self;
}

- (void)dealloc {
    [_recordType release];
    [_maxModificationDate release];
    _maxModificationDate = nil;
    [_queryCursor release];
    _queryCursor = nil;
    [_zoneIDToQuery release];
    [super dealloc];
}

- (NSString *)description {
    // self = x19
    // x20
    NSMutableString *result = [[NSMutableString alloc] initWithString:[super description]];
    /*
     x9 = _zoneIDToQuery
     x10 = _recordType
     x8 = _maxModificationDate ?? @"nil"
     */
    
    [result appendFormat:@" { %@:%@:%@ }", _zoneIDToQuery, _recordType, (_maxModificationDate == nil) ? @"nil" : _maxModificationDate];
    
    return [result autorelease];
}

- (void)addUpdatedRecord:(CKRecord *)record {
    /*
     self = x20
     record = x19
     */
    if (self->_encounteredErrors.count == 0) {
        if (self->_maxModificationDate == nil) {
            self->_maxModificationDate = [record.modificationDate retain];
        } else {
            if ([self->_maxModificationDate compare:record.modificationDate] == NSOrderedAscending) {
                [self->_maxModificationDate release];
                self->_maxModificationDate = [record.modificationDate retain];
            }
        }
    }
    
    [super addUpdatedRecord:record];
}

- (BOOL)applyAccumulatedChangesToStore:(NSSQLCore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext withStoreMonitor:(OCCloudKitStoreMonitor *)monitor madeChanges:(BOOL *)madeChanges error:(NSError * _Nullable *)error {
    /*
     self = x20
     store = x22
     managedObjectContext = x21
     monitor = x23
     error = x19
     */
    // sp, #0x80
    __block NSError * _Nullable _error = nil;
    // sp, #0x60
    __block BOOL _succeed = [super applyAccumulatedChangesToStore:store inManagedObjectContext:managedObjectContext withStoreMonitor:monitor madeChanges:madeChanges error:&_error];
    
    @try {
        if (!_succeed) {
            if (error != NULL) {
                *error = [[_error retain] autorelease];
            } else {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            }
            _error = nil;
            return NO;
        }
        
        // <+184>
        if (monitor.declaredDead) {
            return YES;
        }
        
        // <+196>
        /*
         __130-[PFCloudKitCKQueryBackedImportWorkItem applyAccumulatedChangesToStore:inManagedObjectContext:withStoreMonitor:madeChanges:error:]_block_invoke
         self = sp + 0x28 = x19 + 0x20
         store = sp + 0x30 = x19 + 0x28
         managedObjectContext = sp + 0x38 = x19 + 0x30
         _error = sp + 0x40 = x19 + 0x38
         _succeed = sp + 0x48 = x19 + 0x40
         */
        [managedObjectContext performBlockAndWait:^{
            // self(block) = x19
            @try {
                OCCKRecordZoneMetadata * _Nullable zoneMetadata = [OCCKRecordZoneMetadata zoneMetadataForZoneID:self.zoneIDToQuery inDatabaseWithScope:self.options.database.databaseScope forStore:store inContext:managedObjectContext error:&_error];
                // <+112>
            } @catch (NSException *exception) {
                abort();
            }
        }];
    } @catch (NSException *exception) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: %@ - Exception thrown during query import: %@\n", self, exception);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: %@ - Exception thrown during query import: %@\n", self, exception);
    } @finally {
        if (!_succeed) {
            if (error != NULL) {
                *error = [[_error retain] autorelease];
            } else {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            }
            _error = nil;
            return NO;
        }
        
        return YES;
    }
}

@end
