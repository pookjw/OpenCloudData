//
//  OCCloudKitMetadataModelMigrator.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/29/25.
//

#import <OpenCloudData/OCCloudKitMetadataModelMigrator.h>
#import <OpenCloudData/NSSQLBlockRequestContext.h>
#import <OpenCloudData/Log.h>
#import <OpenCloudData/NSManagedObjectContext+Private.h>
#import <OpenCloudData/NSSQLiteConnection.h>
#import <OpenCloudData/OCCloudKitMetadataModel.h>
#import <OpenCloudData/NSSQLModel.h>
#import <objc/runtime.h>
@import ellekit;

COREDATA_EXTERN NSString * const PFCloudKitMetadataNeedsZoneFetchAfterClientMigrationKey;

@implementation OCCloudKitMetadataModelMigrator

- (instancetype)initWithStore:(NSSQLCore *)store metadataContext:(NSManagedObjectContext *)metadataContext databaseScope:(CKDatabaseScope)databaseScope metricsClient:(OCCloudKitMetricsClient *)metricsClient {
    /*
     store = x23
     metadataContext = x22
     databaseScope = x20
     metricsClient = x19
     */
    if (self = [super init]) {
        _store = [store retain];
        _metadataContext = [metadataContext retain];
        // original : NSCloudKitMirroringDelegateMigrationAuthor
        metadataContext.transactionAuthor = @"NSCloudKitMirroringDelegate.migration";
        _context = [[OCCloudKitMetadataMigrationContext alloc] init];
        _databaseScope = databaseScope;
        _metricsClient = [metricsClient retain];
    }
    
    return self;
}

- (void)dealloc {
    [_store release];
    [_metadataContext release];
    [_context release];
    [_metricsClient release];
    [super dealloc];
}

- (BOOL)checkAndPerformMigrationIfNecessary:(NSError * _Nullable *)error {
    /*
     self = x20
     error = x19
     */
    
    // sp, #0x68
    __block BOOL _succeed = YES;
    // sp, #0x38
    __block NSError * _Nullable _error = nil;
    
    /*
     __71-[PFCloudKitMetadataModelMigrator checkAndPerformMigrationIfNecessary:]_block_invoke
     self = sp + 0x20 = x27 + 0x20
     _succeed = sp + 0x28 = x27 + 0x28
     _error = sp + 0x30 = x27 + 0x30
     */
    // x21
    NSSQLBlockRequestContext *requestContext = [[objc_lookUpClass("NSSQLBlockRequestContext") alloc] initWithBlock:^(NSSQLStoreRequestContext * _Nullable context) {
        /*
         self(block) = x27
         context = x20
         self = x21
         */
        
        _succeed = YES;
        
        // x26
        NSSQLiteConnection * _Nullable connection;
        {
            if (context == nil) {
                connection = nil;
            } else {
                assert(object_getInstanceVariable(context, "_connection", (void **)&connection) != NULL);
            }
        }
        
        // <+84>
        _succeed = [self prepareContextWithConnection:connection error:&_error];
        abort();
    }
                                                                                                           context:nil
                                                                                                           sqlCore:_store];
    
    const void *image = MSGetImageByName("/System/Library/Frameworks/CoreData.framework/CoreData");
    const void *symbol = MSFindSymbol(image, "-[NSManagedObjectContext _countForFetchRequest_:error:]");
    
    ((void (*)(id, id, NSUInteger))symbol)(_store, requestContext, 0);
    [requestContext release];
    
    if (!_succeed) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
        } else {
            if (error != NULL) {
                *error = [[_error retain] autorelease];
            }
        }
        
        [_error release];
        return _succeed;
    }
    
    _succeed = [self commitMigrationMetadataAndCleanup:&_error];
    
    if (!_succeed) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
        } else {
            if (error != NULL) {
                *error = [[_error retain] autorelease];
            }
        }
    }
    
    return _succeed;
}

- (BOOL)commitMigrationMetadataAndCleanup:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct)) {
    // inlined from -[PFCloudKitMetadataModelMigrator checkAndPerformMigrationIfNecessary:]
    // sp, #0xf0
    __block BOOL _succeed = YES;
    // sp, #0xc0
    __block NSError * _Nullable _error = nil;
    
    /*
     __69-[PFCloudKitMetadataModelMigrator commitMigrationMetadataAndCleanup:]_block_invoke
     self = sp + 0xa8
     _succeed = sp + 0xb0
     _error = sp + 0xb8
     */
    [_metadataContext performBlockAndWait:^{
        abort();
    }];
    
    if (!_succeed) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
        } else {
            if (error != NULL) {
                *error = [[_error retain] autorelease];
            }
        }
        
        [_error release];
        return NO;
    }
    
    if (_databaseScope == CKDatabaseScopePrivate) {
        // inlined
        _succeed = [self checkForRecordMetadataZoneCorruptionInStore:_store error:&_error];
        
        if (!_succeed) {
            if (_error == nil) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
            } else {
                if (error != NULL) {
                    *error = [[_error retain] autorelease];
                }
            }
        }
    }
    
    [_error release];
    return _succeed;
}

- (BOOL)checkForRecordMetadataZoneCorruptionInStore:(NSSQLCore *)store error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct)) {
    // inlined from -[PFCloudKitMetadataModelMigrator checkAndPerformMigrationIfNecessary:]
    /*
     self = x20
     store = x22
     error = sp, #0x38 (from -[PFCloudKitMetadataModelMigrator checkAndPerformMigrationIfNecessary:])
     */
    
    // sp, #0x140
    __block BOOL _succeed = YES;
    // sp, #0x110
    __block NSError * _Nullable _error = nil;
    
    // x21
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [store.persistentStoreCoordinator retain];
    // x23
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    context.persistentStoreCoordinator = persistentStoreCoordinator;
    [context _setAllowAncillaryEntities:YES];
    
    /*
     __85-[PFCloudKitMetadataModelMigrator checkForRecordMetadataZoneCorruptionInStore:error:]_block_invoke
     self = x29 - 0xc0
     store = x29 - 0xb8
     context = x29 - 0xb0
     persistentStoreCoordinator = x29 - 0xa8
     _error = x29 - 0xa0
     _succeed = x29 - 0x98
     */
    [context performBlockAndWait:^{
        abort();
    }];
    
    [context release];
    
    if (!_succeed) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
        } else {
            if (error != NULL) {
                *error = [[_error retain] autorelease];
            }
        }
    }
    
    [persistentStoreCoordinator release];
    [_error release];
    
    return _succeed;;
}

- (BOOL)prepareContextWithConnection:(NSSQLiteConnection *)connection error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct)) {
    // inlined from __71-[PFCloudKitMetadataModelMigrator checkAndPerformMigrationIfNecessary:]_block_invoke
    /*
     self = x21
     connection = x26
     error = sp + 0x8
     */
    // sp, #0x10
    __block BOOL _succeed = YES;
    // sp, #0xf8
    __block NSError * _Nullable _error = nil;
    
    const void *image = MSGetImageByName("/System/Library/Frameworks/CoreData.framework/CoreData");
    const void *_getPFBundleVersionNumber = MSFindSymbol(image, "+[_PFRoutines _getPFBundleVersionNumber]");
    NSNumber *version = ((id (*)(Class))_getPFBundleVersionNumber)(objc_lookUpClass("_PFRoutines"));
    
    // x22
    NSManagedObjectModel *model = [OCCloudKitMetadataModel newMetadataModelForFrameworkVersion:version];
    // x23
    NSSQLModel *sqlModel = [[objc_lookUpClass("NSSQLModel") alloc] initWithManagedObjectModel:model];
    self->_context.currentModel = model;
    self->_context.sqlModel = sqlModel;
    
    // sp, #0xf0
    BOOL hasOldMetadataTables = NO;
    // x24
    NSManagedObjectModel *storeMetadataModel = [OCCloudKitMetadataModel identifyModelForStore:self->_store withConnection:connection hasOldMetadataTables:&hasOldMetadataTables];
    // x25
    NSSQLModel *storeSQLModel = [[objc_lookUpClass("NSSQLModel") alloc] initWithManagedObjectModel:storeMetadataModel];
    self->_context.storeMetadataModel = storeMetadataModel;
    self->_context.storeSQLModel = storeSQLModel;
    
#warning TODO
    if ([self->_store.metadata objectForKey:PFCloudKitMetadataNeedsZoneFetchAfterClientMigrationKey] == nil) {
        // <+404>
        abort();
    }
    // <+404>
    abort();
}

@end
