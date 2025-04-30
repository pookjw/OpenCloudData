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
#import <OpenCloudData/NSKnownKeysDictionary.h>
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
        // w19
        BOOL result = [self prepareContextWithConnection:connection error:&_error];
        // <+1068>
        
        if (!result) {
            _succeed = NO;
            [_error retain];
            return;
        }
        
        result = [self calculateMigrationStepsWithConnection:connection error:&_error];
        if (!result) {
            _succeed = NO;
            [_error retain];
            return;
        }
        
        _succeed = [self _redacted_1:connection error:&_error];
        if (!_succeed) {
            [_error retain];
        }
    }
                                                                                                           context:nil
                                                                                                           sqlCore:_store];
    
    const void *image = MSGetImageByName("/System/Library/Frameworks/CoreData.framework/CoreData");
    const void *symbol = MSFindSymbol(image, "-[NSManagedObjectContext dispatchRequest:error:]");
    
    ((void (*)(id, id, NSUInteger))symbol)(_store, requestContext, 0);
    [requestContext release];
    
    if (!_succeed) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
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
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
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
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
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
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
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
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
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
    const void *_PFRoutines_getPFBundleVersionNumber = MSFindSymbol(image, "+[_PFRoutines _getPFBundleVersionNumber]");
    const void *NSSQLiteConnection_hasTableWithName_isTemp_ = MSFindSymbol(image, "-[NSSQLiteConnection _hasTableWithName:isTemp:]");
    NSNumber *version = ((id (*)(Class))_PFRoutines_getPFBundleVersionNumber)(objc_lookUpClass("_PFRoutines"));
    
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
    
    if ([self->_store.metadata objectForKey:PFCloudKitMetadataNeedsZoneFetchAfterClientMigrationKey] != nil) {
        OCCloudKitMetadataMigrationContext * _Nullable context = self->_context;
        if (context != nil) {
            context->_needsImportAfterClientMigration = _succeed;
        }
    }
    
//    NSSQLEntity *sqlEntity = [sqlModel entityNamed:NSStringFromClass([OCCKMetadataEntry class])];
    NSSQLEntity *sqlEntity = [sqlModel entityNamed:NSStringFromClass(objc_lookUpClass("NSCKMetadataEntry"))];
    NSString *tableName = [sqlEntity tableName];
    BOOL hasTable = ((BOOL (*)(id, id, BOOL))NSSQLiteConnection_hasTableWithName_isTemp_)(connection, tableName, NO);
    
    if (hasTable) {
        NSKnownKeysDictionary<NSString *, NSSQLEntity *> *entitiesByName;
        assert(object_getInstanceVariable(sqlModel, "_entitiesByName", (void **)&entitiesByName) != NULL);
        
        // sp + 0xc8
        __block BOOL mutated = NO;
        /*
         __70-[PFCloudKitMetadataModelMigrator prepareContextWithConnection:error:]_block_invoke
         */
        [entitiesByName enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull entityName, NSSQLEntity * _Nonnull entity, BOOL * _Nonnull stop) {
            abort();
        }];
        
        if (mutated) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Migration discovered mutated entity IDs, precomputing z_ent changes.", __func__, __LINE__);
            _succeed = [self computeAncillaryEntityPrimaryKeyTableEntriesForStore:self->_store error:&_error];
            
            if (!_succeed) {
                [_error retain];
            }
        }
        
        /*
         __70-[PFCloudKitMetadataModelMigrator prepareContextWithConnection:error:]_block_invoke.8
         */
        [self->_metadataContext performBlockAndWait:^{
            abort();
        }];
    } else {
        OCCloudKitMetadataMigrationContext * _Nullable context = self->_context;
        if (context != nil) {
            context->_needsMetdataMigrationToNSCKRecordMetadata = YES;
            context->_needsBatchUpdateForSystemFieldsAndLastExportedTransaction = YES;
        }
    }
    
    [model release];
    [sqlModel release];
    [storeMetadataModel release];
    [storeSQLModel release];
    
    if (!_succeed) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) {
                *error = [[_error retain] autorelease];
            }
        }
    }
    
    [_error release];
    
    // <+1036>
    return _succeed;
}

- (BOOL)computeAncillaryEntityPrimaryKeyTableEntriesForStore:(NSSQLCore *)store error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct)) {
    abort();
}

- (BOOL)calculateMigrationStepsWithConnection:(NSSQLiteConnection *)connection error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct)) {
    abort();
}

- (BOOL)_redacted_1:(NSSQLiteConnection *)connection error:(NSError * _Nullable * _Nonnull)error __attribute__((objc_direct)) {
    // inlined from __71-[PFCloudKitMetadataModelMigrator checkAndPerformMigrationIfNecessary:]_block_invoke <+1108>~<+1708>
    /*
     self = x25
     connection = x20
     error = x24
     */
    
    BOOL hasWorkToDo;
    {
        OCCloudKitMetadataMigrationContext * _Nullable context = self->_context;
        if (context == nil) {
            hasWorkToDo = NO;
        } else {
            hasWorkToDo = context->_hasWorkToDo;
        }
    }
    
    const void *image = MSGetImageByName("/System/Library/Frameworks/CoreData.framework/CoreData");
    const void *NSSQLiteConnection_connect = MSFindSymbol(image, "-[NSSQLiteConnection connect]");
    const void *NSSQLiteConnection_beginTransaction = MSFindSymbol(image, "-[NSSQLiteConnection beginTransaction]");
    // dedup = de + duplicate = 중복 제거
    const void *NSSQLiteConnection_dedupeRowsForUniqueConstraintsInCloudKitMetadataEntity_ = MSFindSymbol(image, "-[NSSQLiteConnection dedupeRowsForUniqueConstraintsInCloudKitMetadataEntity:]");
    const void *NSSQLiteConnection_prepareAndExecuteSQLStatement_ = MSFindSymbol(image, "-[NSSQLiteConnection prepareAndExecuteSQLStatement:]");
    const void *NSSQLiteConnection_createTablesForEntities_ = MSFindSymbol(image, "-[NSSQLiteConnection createTablesForEntities:]");
    const void *NSSQLiteConnection_commitTransaction = MSFindSymbol(image, "-[NSSQLiteConnection commitTransaction]");
    const void *NSSQLiteConnection_endFetchAndRecycleStatement_ = MSFindSymbol(image, "-[NSSQLiteConnection endFetchAndRecycleStatement]");
    const void *NSSQLiteConnection_rollbackTransaction = MSFindSymbol(image, "-[NSSQLiteConnection rollbackTransaction]");
    const void *NSSQLiteConnection_disconnect = MSFindSymbol(image, "-[NSSQLiteConnection disconnect]");
    
    // w26
    BOOL shouldRollback;
    // w25
    BOOL shouldReconnect;
    // w23
    BOOL succeed;
    // x21
    NSError * _Nullable _error;
    
    if (hasWorkToDo) {
        @try {
            ((void (*)(id))NSSQLiteConnection_connect)(connection);
            ((void (*)(id))NSSQLiteConnection_beginTransaction)(connection);
            
            // x21
            NSMutableSet<NSSQLEntity *> * _Nullable constrainedEntitiesToPreflight;
            {
                OCCloudKitMetadataMigrationContext * _Nullable context = self->_context;
                if (context == nil) {
                    constrainedEntitiesToPreflight = nil;
                } else {
                    constrainedEntitiesToPreflight = context->_constrainedEntitiesToPreflight;
                }
            }
            
            for (NSSQLEntity *entity in constrainedEntitiesToPreflight) {
                ((void (*)(id, id))NSSQLiteConnection_dedupeRowsForUniqueConstraintsInCloudKitMetadataEntity_)(connection, entity);
            }
            
            for (NSSQLEntity *entity in constrainedEntitiesToPreflight) {
                ((void (*)(id, id))NSSQLiteConnection_prepareAndExecuteSQLStatement_)(connection, entity);
            }
            
            NSMutableArray<NSSQLEntity *> * _Nullable sqlEntitiesToCreate;
            {
                OCCloudKitMetadataMigrationContext * _Nullable context = self->_context;
                if (context == nil) {
                    sqlEntitiesToCreate = nil;
                } else {
                    sqlEntitiesToCreate = context->_sqlEntitiesToCreate;
                }
            }
            
            ((void (*)(id, id))NSSQLiteConnection_createTablesForEntities_)(connection, sqlEntitiesToCreate);
            ((void (*)(id))NSSQLiteConnection_commitTransaction)(connection);
            
            shouldRollback = NO;
            shouldReconnect = NO;
            _error = nil;
            succeed = YES;
        } @catch (NSException *exception /* x22 */) {
            shouldRollback = YES;
            
            // TODO: Domain/Code 검증
            _error = [NSError errorWithDomain:NSCocoaErrorDomain code:11180 userInfo:@{@"NSUnderlyingException": exception}];
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Exception caught during execution of migration statement for cloudkit metadata tables %@ with userInfo %@\n%@\n%@\n", exception, exception.userInfo, self->_store, self->_metadataContext);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Exception caught during execution of migration statement for cloudkit metadata tables %@ with userInfo %@\n%@\n%@\n", exception, exception.userInfo, self->_store, self->_metadataContext);
            
            succeed = NO;
            shouldReconnect = YES;
        }
    } else {
        shouldRollback = NO;
        shouldReconnect = NO;
        _error = nil;
        succeed = YES;
    }
    
    @try {
        ((void (*)(id, BOOL))NSSQLiteConnection_endFetchAndRecycleStatement_)(connection, NO);
    } @catch (NSException *exception /* x22 */) {
        shouldRollback = YES;
        _error = [NSError errorWithDomain:NSCocoaErrorDomain code:11180 userInfo:@{NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"An unhandled exception was thrown during CloudKit metadata migration: %@", exception]}];
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Exception caught during execution of migration statement for cloudkit metadata tables %@\n%@\n%@\n", exception, self->_store, self->_metadataContext);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Exception caught during execution of migration statement for cloudkit metadata tables %@\n%@\n%@\n", exception, self->_store, self->_metadataContext);
        
        succeed = NO;
        shouldReconnect = YES;
    }
    
    if (shouldRollback) {
        ((void (*)(id, BOOL))NSSQLiteConnection_rollbackTransaction)(connection, NO);
    }
    if (shouldReconnect) {
        ((void (*)(id))NSSQLiteConnection_disconnect)(connection);
        ((void (*)(id))NSSQLiteConnection_connect)(connection);
    }
    
    if (!succeed) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            // null 확인 없음
            *error = _error;
        }
    }
    
    return succeed;
}

@end
