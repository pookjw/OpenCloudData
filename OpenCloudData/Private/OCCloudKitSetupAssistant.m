//
//  OCCloudKitSetupAssistant.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/26/25.
//

#import "OpenCloudData/Private/OCCloudKitSetupAssistant.h"
#import "OpenCloudData/Private/Log.h"
#import "OpenCloudData/SPI/CloudKit/CKContainer+Private.h"
#import "OpenCloudData/SPI/CloudKit/CKModifyRecordsOperation+Private.h"
#import "OpenCloudData/Private/OCCloudKitSerializer.h"
#import "OpenCloudData/SPI/OCSPIResolver.h"
#import "OpenCloudData/Private/OCCloudKitMetadataModel.h"
#import "OpenCloudData/Private/Model/OCCKEvent.h"
#import "OpenCloudData/SPI/CoreData/_PFRoutines.h"
#import "OpenCloudData/Private/Model/OCCKMetadataEntry.h"
#include <objc/runtime.h>

CK_EXTERN NSString * _Nullable CKDatabaseScopeString(CKDatabaseScope);

@implementation OCCloudKitSetupAssistant

- (instancetype)initWithSetupRequest:(OCCloudKitMirroringDelegateSetupRequest *)setupRequest mirroringOptions:(OCCloudKitMirroringDelegateOptions *)mirroringOptions observedStore:(NSSQLCore *)observedStore {
    /*
     setupRequest = x22
     mirroringOptions = x21
     observedStore = x19
     */
    if (self = [super init]) {
        _setupRequest = [setupRequest retain];
        _cloudKitSemaphore = dispatch_semaphore_create(0);
        _mirroringOptions = [mirroringOptions retain];
        _storeMonitor = [_mirroringOptions.storeMonitorProvider createMonitorForObservedStore:observedStore inTransactionWithLabel:nil];
    }
    
    return self;
}

- (void)dealloc {
    [_setupRequest release];
    [_setupEvent release];
    [_container release];
    _container = nil;
    [_database release];
    _database = nil;
    [_databaseSubscription release];
    _databaseSubscription = nil;
    [_largeBlobDirectoryURL release];
    _largeBlobDirectoryURL = nil;
    [_mirroringOptions release];
    [_storeMonitor release];
    [_currentUserRecordID release];
    _currentUserRecordID = nil;
    if (_cloudKitSemaphore != nil) {
        dispatch_release(_cloudKitSemaphore);
    }
    [super dealloc];
}

- (BOOL)_initializeCloudKitForObservedStore:(NSError **)error andNoteMetadataInitialization:(BOOL *)metadataInitializationPtr {
    /*
     self = x20
     error = x19
     metadataInitializationPtr = x22
     */
    // w23
    BOOL skipCloudKitSetup = self->_mirroringOptions.skipCloudKitSetup;
    
    BOOL _succeed = YES;
    NSError * _Nullable _error = nil;
    
    // <+96>
    _succeed = [self _checkAndInitializeMetadata:&_error];
    // <+348>
    
    if (!_succeed) {
        if (_error == nil) {
            // <+900>
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) *error = _error;
        }
        
        return NO;
    }
    
    if (skipCloudKitSetup) {
        // <+372>
        _succeed = [self _initializeAssetStorageURLError:&_error];
        
        if (!_succeed) {
            if (_error == nil) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            } else {
                if (error != NULL) *error = _error;
            }
        }
        
        return _succeed;
    }
    
    // <+556>
    _succeed = [self _checkAccountStatus:&_error];
    // <+193<+796>6>
    if (!_succeed) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) *error = _error;
        }
        
        return NO;
    }
    
    // <+1944>
    _succeed = [self _checkUserIdentity:&_error];
    // <+3124>
    if (!_succeed) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) *error = _error;
        }
        
        return NO;
    }
    
    // <+3132>
    _succeed = [self _recoverFromManateeIdentityLossIfNecessary:&_error];
    // <+4860>
    if (!_succeed) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) *error = _error;
        }
        
        return NO;
    }
    
    // <+5284>
    _succeed = [self _setupDatabaseSubscriptionIfNecessary:&_error];
    if (!_succeed) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) *error = _error;
        }
        
        return NO;
    }
    
    // <+7936>
    return YES;
}

- (void)beginActivityForPhase:(NSUInteger)phase {
    // self = x19
    __kindof OCPersistentCloudKitContainerActivity *activity = [_setupRequest.activity beginActivityForPhase:phase];
    [_mirroringOptions.progressProvider publishActivity:activity];
    [activity release];
}

- (void)endActivityForPhase:(NSUInteger)phase withError:(NSError *)error {
    // self = x19
    __kindof OCPersistentCloudKitContainerActivity *activity = [_setupRequest.activity endActivityForPhase:phase withError:error];
    [_mirroringOptions.progressProvider publishActivity:activity];
    [activity release];
}

- (BOOL)_checkAndInitializeMetadata:(NSError * _Nullable *)error {
    // inlined from -[PFCloudKitSetupAssistant _initializeCloudKitForObservedStore:andNoteMetadataInitialization:] <+96>~<+348>
    // sp, #0x20
    __block BOOL _succeed = YES;
    // sp, #0xe0
    __block NSError * _Nullable _error = nil;
    
    [self beginActivityForPhase:1];
    
    OCCloudKitStoreMonitor *storeMonitor = _storeMonitor;
    /*
     __56-[PFCloudKitSetupAssistant _checkAndInitializeMetadata:]_block_invoke
     storeMonitor = sp + 0x170 = x20 + 0x20
     self = sp + 0x178 = x20 + 0x28
     _succeed = sp + 0x180 = x20 + 0x30
     _error = sp + 0x188 = x20 + 0x38
     */
    [storeMonitor performBlock:^{
        // self = x20
        // x19
        NSSQLCore *store = [storeMonitor retainedMonitoredStore];
        if (store == nil) {
            // <+432>
            _succeed = NO;
            _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134060 userInfo:@{
                NSLocalizedFailureReasonErrorKey: @"The mirroring delegate could not initialize because it's store was removed from the coordinator."
            }];
            return;
        }
        
        // <+72>
        // x21
        NSPersistentStore *monitoredStore = [storeMonitor.monitoredStore retain];
        // x22
        NSManagedObjectContext *managedObjectContext = [storeMonitor newBackgroundContextForMonitoredCoordinator];
        managedObjectContext.transactionAuthor = [OCSPIResolver NSCloudKitMirroringDelegateSetupAuthor];
        
        /*
         __56-[PFCloudKitSetupAssistant _checkAndInitializeMetadata:]_block_invoke_2
         store = sp + 0x28 = x19 + 0x20
         managedObjectContext = sp + 0x30 = x19 + 0x28
         self = sp + 0x38 = x19 + 0x30
         */
        [managedObjectContext performBlockAndWait:^{
            // self(block) = x19
            if ([OCSPIResolver _PFRoutines__isInMemoryStore_:objc_lookUpClass("_PFRoutines") x1:store]) {
                return;
            }
            
            // sp, #0x8
            __block NSError * _Nullable __error = nil;
            BOOL result = [managedObjectContext setQueryGenerationFromToken:NSQueryGenerationToken.currentQueryGenerationToken error:&__error];
            
            if (!result) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@: Unable to set query generation on moc: %@", __func__, __LINE__, self, __error);
            }
        }];
        
        _succeed = [OCCloudKitMetadataModel checkAndRepairSchemaOfStore:store withManagedObjectContext:managedObjectContext error:&_error];
        
        if (!_succeed) {
            [_error retain];
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Failed to initialize CloudKit metadata: %@", __func__, __LINE__, _error);
            [managedObjectContext release];
            [monitoredStore release];
            [store release];
            return;
        }
        
        // <+256>
        _succeed = [self _checkAndTruncateEventHistoryIfNeededWithManagedObjectContext:managedObjectContext error:&_error];
        
        // <+656>
        if (!_succeed) {
            _succeed = NO;
            [_error retain];
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Failed to initialize CloudKit metadata: %@", __func__, __LINE__, _error);
            [managedObjectContext release];
            [monitoredStore release];
            [store release];
            return;
        }
        
        // x23
        OCPersistentCloudKitContainerEvent *event = [OCCKEvent beginEventForRequest:_setupRequest withMonitor:storeMonitor error:&_error];
        
        if (event == nil) {
            _succeed = NO;
            [_error retain];
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Failed to initialize CloudKit metadata: %@", __func__, __LINE__, _error);
            [managedObjectContext release];
            [monitoredStore release];
            [store release];
            return;
        }
        
        _setupEvent = [event retain];
        [_mirroringOptions.progressProvider eventUpdated:event];
        [event release];
        
        [managedObjectContext release];
        [monitoredStore release];
        [store release];
    }];
    
    [self endActivityForPhase:1 withError:_error];
    
    if (!_succeed) {
        // <+276>
        if (_error == nil) {
            // <+900>
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            *error = [[_error retain] autorelease];
        }
        
        // <+300>
        [_error release];
        _error = nil;
        return NO;
    }
    
    // <+300>
    [_error release];
    _error = nil;
    return YES;
}

- (BOOL)_checkAndTruncateEventHistoryIfNeededWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    // inlined from __56-[PFCloudKitSetupAssistant _checkAndInitializeMetadata:]_block_invoke <+256>~<+652>
    // managedObjectContext = x22
    // sp, #0x60
    __block NSError * _Nullable _error = nil;
    // sp, #0x40
    __block BOOL _succeed = YES;
    
    /*
     __96-[PFCloudKitSetupAssistant _checkAndTruncateEventHistoryIfNeededWithManagedObjectContext:error:]_block_invoke
     managedObjectContext = x29 - 0x80 = x19 + 0x20
     _error = x29 - 0x78 = x19 + 0x28
     _succeed = x29 - 0x70 = x19 + 0x30
     */
    [managedObjectContext performBlockAndWait:^{
        // self(block) = x19
        @try {
            // x20
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:OCCKEvent.entityPath];
            
            if (managedObjectContext == nil) return;
            
            NSInteger count = [OCSPIResolver NSManagedObjectContext__countForFetchRequest__error_:managedObjectContext x1:fetchRequest x2:&_error];
            
            if (count == NSNotFound) {
                _succeed = NO;
                [_error retain];
                return;
            }
            
            // <+148>
            if (count <= 20000L) {
                return;
            }
            
            // <+160>
            fetchRequest.fetchLimit = (count - 10000L);
            fetchRequest.resultType = NSManagedObjectIDResultType;
            fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"SELF" ascending:YES]];
            // x20
            NSArray<NSManagedObjectID *> *objectIDs = [managedObjectContext executeFetchRequest:fetchRequest error:&_error];
            
            if (objectIDs == nil) {
                // <+388>
                _succeed = NO;
                [_error retain];
                return;
            }
            
            // x20
            NSBatchDeleteRequest *deleteRequest = [[NSBatchDeleteRequest alloc] initWithObjectIDs:objectIDs];
            deleteRequest.resultType = NSBatchDeleteResultTypeStatusOnly;
            
            _succeed = ((NSNumber *)((NSBatchDeleteResult *)[managedObjectContext executeRequest:deleteRequest error:&_error])).boolValue;
            if (!_succeed) {
                [_error retain];
            }
            
            [deleteRequest release];
        } @catch (NSException *exception) {
            _succeed = NO;
            _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134421 userInfo:@{
                @"NSUnderlyingException": exception,
                NSLocalizedFailureErrorKey: @"Setup failed because an unhandled exception was caught during event history truncation."
            }];
        }
    }];
    
    if (_succeed) {
        if (_error == nil) {
            // <+900>
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            *error = [[_error retain] autorelease];
        }
    }
    
    [_error release];
    _error = nil;
    return _succeed;
}

- (BOOL)_initializeAssetStorageURLError:(NSError * _Nullable * _Nullable)error {
    // inlined from -[PFCloudKitSetupAssistant _initializeCloudKitForObservedStore:andNoteMetadataInitialization:] <+372>~<+1196>
    [self beginActivityForPhase:6];
    
    // x29 - 0xe0
    __block BOOL _succeed = YES;
    // sp, #0xe0
    __block NSError * _Nullable _error = nil;
    // sp + 0x20
    __block NSURL * _Nullable largeBlobDirectoryURL = nil;
    // x25
    OCCloudKitStoreMonitor *storeMonitor = _storeMonitor;
    
    /*
     __60-[PFCloudKitSetupAssistant _initializeAssetStorageURLError:]_block_invoke
     storeMonitor = sp + 0x170 = x20 + 0x20
     largeBlobDirectoryURL = sp + 0x178 = x20 + 0x28
     _succeed = sp + 0x180 = x20 + 0x30
     _error = sp + 0x188 = x20 + 0x38
     */
    [_storeMonitor performBlock:^{
        // self(block) = x20
        // sp + 0x88
        NSError * _Nullable __error_1 = nil;
        // x23
        NSPersistentStore *store = [storeMonitor retainedMonitoredStore];
        
        if (store == nil) {
            _succeed = NO;
            _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134403 userInfo:@{
                NSLocalizedFailureErrorKey: @"Failed to initialize the asset storage url because the store was removed from the coordinator."
            }];
            return;
        }
        
        // <+68>
        // x24
        NSPersistentStoreCoordinator *monitoredCoordinator = [storeMonitor.monitoredCoordinator retain];
        largeBlobDirectoryURL = [[OCCloudKitSerializer assetStorageDirectoryURLForStore:store] retain];
        
        if (largeBlobDirectoryURL == nil) {
            // <+788>
            _succeed = NO;
            _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134403 userInfo:@{
                NSLocalizedFailureErrorKey: [NSString stringWithFormat:@"Failed to create largeBlobDirectoryURL with observed store: %@", store]
            }];
            return;
        }
        
        // <+140>
        // x22
        NSFileManager *fileManager = [NSFileManager.defaultManager retain];
        BOOL isDirectory = NO;
        BOOL exists = [fileManager fileExistsAtPath:largeBlobDirectoryURL.path isDirectory:&isDirectory];
        
        if (!exists) {
            // <+960>
            _succeed = [fileManager createDirectoryAtURL:largeBlobDirectoryURL withIntermediateDirectories:YES attributes:nil error:&__error_1];
            
            if (!_succeed) {
                _error = [__error_1 retain];
                [fileManager release];
                [monitoredCoordinator release];
                [store release];
                return;
            }
            
            // <+1048>
            _succeed = [largeBlobDirectoryURL setResourceValues:@{NSURLIsExcludedFromBackupKey: @YES} error:&__error_1];
            if (!_succeed) {
                [__error_1 retain];
                [fileManager release];
                [monitoredCoordinator release];
                [store release];
                return;
            }
            
            // <+1156>
        } else {
            // <+228>
            // x23
            NSArray<NSString *> *subpaths = [fileManager subpathsAtPath:largeBlobDirectoryURL.path];
            // sp, #0x78
            NSError * _Nullable __error_2 = nil;
            
            for (NSString *subpath in subpaths) {
                // x27
                NSURL *appendedURL = [largeBlobDirectoryURL URLByAppendingPathComponent:subpath];
                BOOL result = [fileManager removeItemAtURL:appendedURL error:&__error_2];
                if (result) continue;
                
                int ulResult = unlink(appendedURL.path.fileSystemRepresentation);
                if (ulResult != 0) {
                    // <+408>
                    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Failed to asset file (and unlink:%d) at url: %@\n%@", __func__, __LINE__, *__error(), appendedURL, __error_2);
                }
            }
            
            // <+624>
            if (!_succeed) {
                // 불릴 일은 없을듯? __error_2는 for-loop 안에서만 쓰임
                [__error_1 retain];
                [fileManager release];
                [monitoredCoordinator release];
                [store release];
                return;
            }
            // <+1156>
        }
        
        // <+1156>
        // x19
        NSURL *oldURL = [OCCloudKitSerializer oldAssetStorageDirectoryURLForStore:store];
        if ([fileManager fileExistsAtPath:oldURL.path]) {
            _succeed = [fileManager removeItemAtURL:oldURL error:&__error_1];
        }
        
        [__error_1 retain];
        [fileManager release];
        [monitoredCoordinator release];
        [store release];
    }];
    
    [self endActivityForPhase:6 withError:_error];
    
    if (!_succeed) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) *error = [[_error retain] autorelease];
        }
        
        [_error release];
        _error = nil;
        
        return NO;
    }
    
    // <+1100>
    _largeBlobDirectoryURL = [largeBlobDirectoryURL retain];
    [largeBlobDirectoryURL release];
    largeBlobDirectoryURL = nil;
    
    return YES;
}

- (BOOL)_checkAccountStatus:(NSError * _Nullable *)error {
    // inlined from -[PFCloudKitSetupAssistant _initializeCloudKitForObservedStore:andNoteMetadataInitialization:] <+556>~<+1936>
    // sp, #0x90
    __block BOOL _succeed = YES;
    // sp, #0x20
    __block NSError * _Nullable _error = nil;
    // x29, #0xe0
    __block NSString * _Nullable userIdentity = nil;
    
    // x22
    CKContainer *container = [[_mirroringOptions.containerProvider containerWithIdentifier:_mirroringOptions.containerIdentifier options:_mirroringOptions.containerOptions] retain];
    
    [self beginActivityForPhase:2];
    
    // x24
    OCCloudKitStoreMonitor *storeMonitor = [_storeMonitor retain];
    
    // <+744>
    /*
     __48-[PFCloudKitSetupAssistant _checkAccountStatus:]_block_invoke
     storeMonitor = sp + 0x100 = x20 + 0x20
     _error = sp + 0x108 = x20 + x28
     userIdentity = sp + 0x110 = x20 + 0x30
     _succeed = sp + 0x118 = x20 + 0x38
     */
    [storeMonitor performBlock:^{
        // self(block) = x20
        // x19
        NSPersistentStore *store = [storeMonitor retainedMonitoredStore];
        
        if (store == nil) {
            _succeed = NO;
            _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134060 userInfo:@{
                NSLocalizedFailureErrorKey: @"The mirroring delegate could not initialize because it's store was removed from the coordinator."
            }];
            return;
        }
        
        // x21
        NSManagedObjectContext *managedObjectContext = [storeMonitor newBackgroundContextForMonitoredCoordinator];
        managedObjectContext.transactionAuthor = [OCSPIResolver NSCloudKitMirroringDelegateSetupAuthor];
        
        /*
         __48-[PFCloudKitSetupAssistant _checkAccountStatus:]_block_invoke_2
         store = sp + 0x20 = x19 + 0x20
         managedObjectContext = sp + 0x28 = x19 + 0x28
         _error = sp + 0x30 = x19 + 0x30
         userIdentity = sp + 0x38 = x19 + 0x38
         _succeed = sp + 0x40 = x19 + 0x40
         */
        [managedObjectContext performBlockAndWait:^{
            // self(block) = x19
            OCCKMetadataEntry *entry;
            @try {
                entry = [OCCKMetadataEntry entryForKey:[OCSPIResolver NSCloudKitMirroringDelegateCKIdentityRecordNameDefaultsKey] fromStore:store inManagedObjectContext:managedObjectContext error:&_error];
                if (entry == nil) {
                    if (_error != nil) {
                        _succeed = NO;
                        [_error retain];
                    }
                    return;
                }
            } @catch (NSException *exception) {
                _succeed = NO;
                _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134402 userInfo:@{
                    @"NSUnderlyingException": exception
                }];
                return;
            }
            
            @try {
                userIdentity = [entry.stringValue retain];
            } @catch (NSException *exception) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Unexpected exception thrown during account setup: %@\n", exception);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Unexpected exception thrown during account setup: %@\n", exception);
            }
        }];
        
        [managedObjectContext release];
        [store release];
    }];
    
    if (!_succeed) {
        // <+1336>
        _container = [container retain];
        [self endActivityForPhase:2 withError:_error];
        
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) *error = [[_error retain] autorelease];
        }
        
        [userIdentity release];
        [container release];
        [storeMonitor release];
        [_error release];
        return NO;
    }
    
    if (container == nil) {
        // <+1200>
        _succeed = NO;
        _error = [[NSError errorWithDomain:NSCocoaErrorDomain code:134400 userInfo:@{
            NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Failed to get a container back for the identifier: %@", _mirroringOptions.containerIdentifier]
        }] retain];
        
        // <+1336>
        _container = [container retain];
        [self endActivityForPhase:2 withError:_error];
        
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) *error = [[_error retain] autorelease];
        }
        
        [userIdentity release];
        [container release];
        [storeMonitor release];
        [_error release];
        return NO;
    }
    
    // <+768>
    // x23
    dispatch_semaphore_t cloudKitSemaphore = self.cloudKitSemaphore;
    // x26
    BOOL useDeviceToDeviceEncryption = _mirroringOptions.useDeviceToDeviceEncryption;
    // x25
    dispatch_group_t monitorGroup = [_storeMonitor.monitorGroup retain];
    /*
     __48-[PFCloudKitSetupAssistant _checkAccountStatus:]_block_invoke.20
     monitorGroup = sp + 0x170 = x19 + 0x20
     self = sp + 0x178 = x19 + 0x28
     cloudKitSemaphore = sp + 0x180 = x19 + 0x30
     _succeed = sp + 0x188 = x19 + 0x38
     userIdentity = sp + 0x190 = x19 + 0x40
     _error = sp + 0x198 = x19 + 0x48
     useDeviceToDeviceEncryption = sp + 0x1a0 = x19 + 0x50
     */
    [container accountInfoWithCompletionHandler:^(CKAccountInfo * _Nullable accountInfo, NSError * _Nullable __error) {
        /*
         self(block) = x19
         accountInfo = x21
         __error = x22
         */
        os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Fetched account info for store %@: %@\n%@", __func__, __LINE__, monitorGroup, accountInfo, __error);
        
        if (accountInfo == nil) {
            // <+608>
            // original : getCloudKitCKErrorDomain
            if (([__error.domain isEqualToString:CKErrorDomain]) && (__error.code == CKErrorNotAuthenticated)) {
                // <+668>
                // x20
                NSMutableDictionary<NSErrorUserInfoKey, id> *userInfo = [[NSMutableDictionary alloc] init];
                [userInfo setObject:@"Unable to initialize without an iCloud account (CKErrorNotAuthenticated)." forKey:NSLocalizedFailureReasonErrorKey];
                [userInfo setObject:__error forKey:NSUnderlyingErrorKey];
                _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134400 userInfo:userInfo];
                [userInfo release];
                
                // original : 원래는 없음
                _succeed = NO;
            } else {
                // <+776>
                _succeed = NO;
                [_error retain];
            }
            
            dispatch_semaphore_signal(cloudKitSemaphore);
            return;
        }
        
        // <+232>
        // x23
        NSInteger accountStatus = accountInfo.accountStatus;
        if ((accountStatus != 1) || !(accountInfo.hasValidCredentials)) {
            _succeed = NO;
            
            // x20
            NSMutableDictionary<NSErrorUserInfoKey, id> *userInfo = [[NSMutableDictionary alloc] init];
            if (__error != nil) {
                [userInfo setObject:__error forKey:NSUnderlyingErrorKey];
            }
            if (accountStatus == 3) {
                if (userIdentity != nil) {
                    [userInfo setObject:userIdentity forKey:[OCSPIResolver PFCloudKitOldUserIdentityKey]];
                    [userInfo setObject:@2 forKey:[OCSPIResolver NSCloudKitMirroringDelegateResetSyncReasonKey]];
                    _error = [[NSError errorWithDomain:NSCocoaErrorDomain code:134400 userInfo:userInfo] retain];
                    // <+1152>
                    // fin
                } else {
                    // <+968>
                    if (self->_mirroringOptions.databaseScope == CKDatabaseScopePublic) {
                        // <+988>
                        _error = nil;
                        _succeed = YES;
                        // <+1152>
                        // fin
                    } else {
                        // <+1224>
                        [accountInfo hasValidCredentials]; // ???
                        [userInfo setObject:@"Unable to initialize without an iCloud account (CKAccountStatusNoAccount)." forKey:NSLocalizedFailureReasonErrorKey];
                        _error = [[NSError errorWithDomain:NSCocoaErrorDomain code:134400 userInfo:userInfo] retain];
                        // <+1152>
                        // fin
                    }
                }
            } else if (accountStatus == 4) {
                // <+1084>
                [userInfo setObject:@"Unable to initialize without a valid iCloud account (CKAccountStatusTemporarilyUnavailable)." forKey:NSLocalizedFailureReasonErrorKey];
                _error = [[NSError errorWithDomain:NSCocoaErrorDomain code:134400 userInfo:userInfo] retain];
                // <+1152>
                // fin
            } else if (accountStatus == 2) {
                // <+936>
                [userInfo setObject:@"Unable to initialize without a valid iCloud account (CKAccountStatusRestricted)." forKey:NSLocalizedFailureReasonErrorKey];
                _error = [[NSError errorWithDomain:NSCocoaErrorDomain code:134400 userInfo:userInfo] retain];
                // <+1152>
                // fin
            } else {
                // <+1012>
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Cannot generate a failure reason for an unknown account status: %ld\n", accountStatus);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Cannot generate a failure reason for an unknown account status: %ld\n", accountStatus);
                [userInfo setObject:@"Unknown account status" forKey:NSLocalizedFailureReasonErrorKey];
                _error = [[NSError errorWithDomain:NSCocoaErrorDomain code:134400 userInfo:userInfo] retain];
                // <+1152>
                // fin
            }
            
            [userInfo release];
            dispatch_semaphore_signal(cloudKitSemaphore);
            return;
        }
        
        // <+264>
        if (!useDeviceToDeviceEncryption || (((accountInfo.deviceToDeviceEncryptionAvailability & (1 << 0)) != 0) && ((accountInfo.deviceToDeviceEncryptionAvailability & (1 << 1)) != 0))) {
            // <+948>
            _succeed = YES;
            dispatch_semaphore_signal(cloudKitSemaphore);
            return;
        }
        
        // <+300>
        if (userIdentity != nil) {
            // <+324>
            _succeed = NO;
            // x20
            NSMutableDictionary<NSErrorUserInfoKey, id> *userInfo = [[NSMutableDictionary alloc] init];
            [userInfo setObject:userIdentity forKey:[OCSPIResolver PFCloudKitOldUserIdentityKey]];
            [userInfo setObject:@2 forKey:[OCSPIResolver NSCloudKitMirroringDelegateResetSyncReasonKey]];
            
            _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134400 userInfo:userInfo];
            [userInfo release];
            dispatch_semaphore_signal(cloudKitSemaphore);
            return;
        } else {
            // <+1272>
            _succeed = NO;
            
            NSString *reason;
            if ((accountInfo.deviceToDeviceEncryptionAvailability & (1 << 0)) == 0) {
                // <+1340>
                reason = @"Unable to initialize the CloudKit container because this account does not support device to device encryption.";
            } else {
                // <+1376>
                reason = @"Unable to initialize the CloudKit container because this device does not support device to device encryption.";
            }
            
            _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134400 userInfo:@{
                NSLocalizedFailureReasonErrorKey: reason
            }];
            dispatch_semaphore_signal(cloudKitSemaphore);
            return;
        }
        
    }];
    
    dispatch_semaphore_wait(cloudKitSemaphore, DISPATCH_TIME_FOREVER);
    [monitorGroup release];
    
    // 모두 기존값 release 없음
    // <+1336>
    _container = [container retain];
    
    switch (_mirroringOptions.databaseScope) {
        case CKDatabaseScopeShared:
            _database = [container.sharedCloudDatabase retain];
            break;
        case CKDatabaseScopePrivate:
            _database = [container.privateCloudDatabase retain];
            break;
        case CKDatabaseScopePublic:
            _database = [container.publicCloudDatabase retain];
            break;
        default: {
            // <+1444>
            // original : softLinkCKDatabaseScopeString
            _succeed = NO;
            _error = [[NSError errorWithDomain:NSCocoaErrorDomain code:134400 userInfo:@{
                NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"CloudKit integration does not support the '%@' database scope.", CKDatabaseScopeString(_mirroringOptions.databaseScope)]
            }] retain];
            
            // <+1780>
            [self endActivityForPhase:2 withError:_error];
            
            if (_error == nil) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            } else {
                if (error != NULL) *error = [[_error retain] autorelease];
            }
            
            [userIdentity release];
            [container release];
            [storeMonitor release];
            [_error release];
            return NO;
        }
    }
    
    // <+1600>
    if (_database == nil) {
        // <+1624>
        _succeed = NO;
        // original : softLinkCKDatabaseScopeString
        _succeed = NO;
        _error = [[NSError errorWithDomain:NSCocoaErrorDomain code:134400 userInfo:@{
            NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Failed to get a database back for scope '%@' from container: %@", CKDatabaseScopeString(_mirroringOptions.databaseScope), container]
        }] retain];
    }
    
    // <+1780>
    [self endActivityForPhase:2 withError:_error];
    
    if (_error == nil) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
    } else {
        if (error != NULL) *error = [[_error retain] autorelease];
    }
    
    [userIdentity release];
    [container release];
    [storeMonitor release];
    [_error release];
    return _succeed;
}

- (BOOL)_checkUserIdentity:(NSError * _Nullable *)error {
    // inlined from -[PFCloudKitSetupAssistant _initializeCloudKitForObservedStore:andNoteMetadataInitialization:] <+1944>~<+3124>
    // x29 - 0xb0
    __block BOOL _succeed = NO; // 나중에 0x1를 넣어주는 방식
    
    [self beginActivityForPhase:3];
    
    // sp + 0x20
    __block CKRecordID * _Nullable recordID = nil;
    // x29 - 0xe0
    __block NSError * _Nullable _error = nil;
    
    // x21
    dispatch_semaphore_t cloudKitSemaphore = _cloudKitSemaphore;
    // x22
    NSString *storeIdentifier = [_storeMonitor.storeIdentifier retain];
    
    /*
     __47-[PFCloudKitSetupAssistant _checkUserIdentity:]_block_invoke
     storeIdentifier = sp + 0x170
     cloudKitSemaphore = sp + 0x178
     _succeed = sp + 0x180
     recordID = sp + 0x188
     _error = sp + 0x190
     */
    [_container fetchUserRecordIDWithCompletionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
        abort();
    }];
    
    dispatch_semaphore_wait(cloudKitSemaphore, DISPATCH_TIME_FOREVER);
    
    // x24
    OCCloudKitStoreMonitor *storeMonitor = [_storeMonitor retain];
    
    if (!_succeed) {
        // <+2256>
        // original : getCloudKitCKErrorDomain
        if (([_error.domain isEqualToString:CKErrorDomain]) && (_error.code == CKErrorNotAuthenticated)) {
            // <+2324>
            // sp, #0x90
            __block id _Nullable value = nil;
            
            /*
             __47-[PFCloudKitSetupAssistant _checkUserIdentity:]_block_invoke.82
             storeMonitor = sp + 0x100
             self = sp + 0x108
             _succeed = sp + 0x110
             value = sp + 0x118
             _error = sp + 0x120
             */
            [storeMonitor performBlock:^{
                abort();
            }];
            
            // 아무것도 안하는듯?
            [value release];
            
            if (_error == nil) {
                [self endActivityForPhase:3 withError:nil];
                return YES;
            } else {
                [self endActivityForPhase:3 withError:_error];
                if (error != NULL) *error = [[_error retain] autorelease];
                return NO;
            }
        } else {
            // <+2432>
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@: Identity fetch failed with unknown error: %@", __func__, __LINE__, self, _error);
            
            if (_error == nil) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            } else {
                if (error != NULL) *error = [[_error retain] autorelease];
            }
            
            [self endActivityForPhase:3 withError:_error];
            [storeIdentifier release];
            [recordID release];
            recordID = nil;
            [_error release];
            _error = nil;
            [storeMonitor release];
            return NO;
        }
    }
    
    // <+2148>
    _currentUserRecordID = [recordID retain];
    
    /*
     __47-[PFCloudKitSetupAssistant _checkUserIdentity:]_block_invoke.79
     storeMonitor = sp + 0x100
     self = sp + 0x108
     recordID = sp + 0x110
     _succeed = sp + 0x118
     _error = sp + 0x120
     */
    [storeMonitor performBlock:^{
        abort();
    }];
    
    if (_error == nil) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
    } else {
        if (error != NULL) *error = [[_error retain] autorelease];
    }
    
    [self endActivityForPhase:3 withError:_error];
    [storeIdentifier release];
    [recordID release];
    recordID = nil;
    [_error release];
    _error = nil;
    [storeMonitor release];
    return _succeed;
}

- (BOOL)_recoverFromManateeIdentityLossIfNecessary:(NSError * _Nullable *)error {
    // inlined from -[PFCloudKitSetupAssistant _initializeCloudKitForObservedStore:andNoteMetadataInitialization:] <+3132>~<+4860>
    // x29 - 0xb0
    __block BOOL _succeed = YES;
    // x29 - 0xe0
    __block NSError * _Nullable _error = nil;
    
    [self beginActivityForPhase:4];
    
    switch (_mirroringOptions.databaseScope) {
        case CKDatabaseScopeShared: {
            // <+3956>
            // x24
            NSMutableSet *set_1 = [[NSMutableSet alloc] init];
            // x25
            NSMutableSet *set_2 = [[NSMutableSet alloc] init];
            // x26
            OCCloudKitStoreMonitor *storeMonitor = [_storeMonitor retain];
            
            /*
             __71-[PFCloudKitSetupAssistant _recoverFromManateeIdentityLossIfNecessary:]_block_invoke.54
             storeMonitor = sp + 0x100
             set_2 = sp + 0x108
             _error = sp + 0x110
             _succeed = sp + 0x118
             3 = sp + 0x120
             */
            [storeMonitor performBlock:^{
                abort();
            }];
            
            [storeMonitor release];
            
            if ((_error == nil) && (set_2.count != 0)) {
                // <+4092>
                // x26
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                // original : getCloudKitCKModifyRecordsOperationClass
                // x22
                CKModifyRecordsOperation *operation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:nil recordIDsToDelete:set_2.allObjects];
                [_setupRequest.options applyToOperation:operation];
                operation.markAsParticipantNeedsNewInvitationToken = YES;
                
                /*
                 __71-[PFCloudKitSetupAssistant _recoverFromManateeIdentityLossIfNecessary:]_block_invoke_3.58
                 semaphore = sp + 0x40
                 _succeed = sp + 0x48
                 _error = sp + 0x50
                 */
                operation.modifyRecordsCompletionBlock = ^(NSArray<CKRecord *> * _Nullable savedRecords, NSArray<CKRecordID *> * _Nullable deletedRecordIDs, NSError * _Nullable operationError) {
                    abort();
                };
                
                [_container addOperation:operation];
                [operation release];
                
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                dispatch_release(semaphore);
            }
            
            // <+4284>
            if ((_error == nil) && (set_1.count != 0)) {
                // <+4308>
                // x26
                OCCloudKitStoreMonitor *storeMonitor = [_storeMonitor retain];
                
                /*
                 __71-[PFCloudKitSetupAssistant _recoverFromManateeIdentityLossIfNecessary:]_block_invoke.59
                 storeMonitor = sp + 0x170
                 set_1 = sp + 0x178
                 self = sp + 0x180
                 _error = sp + 0x188
                 _succeed = sp + 0x190
                 3 = sp + 0x198
                 */
                [storeMonitor performBlock:^{
                    abort();
                }];
                
                [storeMonitor release];
            }
            
            // <+4392>
            [set_1 release];
            [set_2 release];
            break;
        }
        case CKDatabaseScopePrivate: {
            // <+3292>
            // x24
            NSMutableSet<CKRecordZoneID *> *set = [[NSMutableSet alloc] init];
            // x25
            OCCloudKitStoreMonitor *storeMonitor = [_storeMonitor retain];
            
            /*
             __71-[PFCloudKitSetupAssistant _recoverFromManateeIdentityLossIfNecessary:]_block_invoke
             storeMonitor = sp + 0x100
             set = sp + 0x108
             _error = sp + 0x110
             _succeed = sp + 0x118
             2 = sp + 0x120
             */
            [storeMonitor performBlock:^{
                abort();
            }];
            
            [storeMonitor release];
            
            // <+3392>
            if (_error != nil) {
                // <+3700>
                [set release];
                *error = [[_error retain] autorelease];
                [_error release];
                return NO;
            }
            
            // x26
            NSArray<CKRecordZoneID *> *recordZoneIDs = set.allObjects;
            
            if (set.count != 0) {
                // <+3416>
                // x25
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                // original : getCloudKitCKModifyRecordZonesOperationClass
                // x22
                CKModifyRecordZonesOperation *operation = [[CKModifyRecordZonesOperation alloc] initWithRecordZonesToSave:nil recordZoneIDsToDelete:recordZoneIDs];
                [_setupRequest.options applyToOperation:operation];
                
                /*
                 __71-[PFCloudKitSetupAssistant _recoverFromManateeIdentityLossIfNecessary:]_block_invoke_3
                 recordZoneIDs = sp + 0x40
                 semaphore = sp + 0x48
                 _succeed = sp + 0x50
                 _error = sp + 0x58
                 */
                operation.modifyRecordZonesCompletionBlock = ^(NSArray<CKRecordZone *> * _Nullable savedRecordZones, NSArray<CKRecordZoneID *> * _Nullable deletedRecordZoneIDs, NSError * _Nullable operationError) {
                    abort();
                };
                
                [_database addOperation:operation];
                [operation release];
                
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                dispatch_release(semaphore);
            }
            
            // <+3592>
            if ((_error == nil) && (set.count != 0)) {
                // <+3616>
                // x25
                OCCloudKitStoreMonitor *storeMonitor = [_storeMonitor retain];
                
                /*
                 __71-[PFCloudKitSetupAssistant _recoverFromManateeIdentityLossIfNecessary:]_block_invoke.50
                 storeMonitor = sp + 0x170
                 set = sp + 0x178
                 self = sp + 0x180
                 _error = sp + 0x188
                 _succeed = sp + 0x190
                 2 = sp + 0x198
                 */
                [storeMonitor performBlock:^{
                    abort();
                }];
                
                [storeMonitor release];
            }
            
            // <+3700>
            [set release];
            break;
        }
        default:
            break;
    }
    
    if (_error != nil) {
        // <+4824>
        *error = [[_error retain] autorelease];
        [_error release];
        return NO;
    }
    
    // <+4880>
    /*
     -endActivityForPhase:withError:를 -_createZoneIfNecessary: 이후에 하는 것을 보아, 여기에 inline된 것 같음
     */
    _succeed = [self _createZoneIfNecessary:&_error];
    // <+5008>
    [self endActivityForPhase:4 withError:_error];
    if (!_succeed) {
        // <+5048>
        *error = [[_error retain] autorelease];
        [_error release];
        return NO;
    }
    
    
    
    abort();
}

- (BOOL)_createZoneIfNecessary:(NSError * _Nullable *)error {
    // inlined from -[PFCloudKitSetupAssistant _initializeCloudKitForObservedStore:andNoteMetadataInitialization:] <+4880>~<+5008>
    
    // sp, #0x1b0
    __block BOOL _succeed = YES;
    // sp, #0x90
    __block NSError * _Nullable _error = nil;
    // sp, #0x70
    __block BOOL flag_1 = YES;
    
    // sp + 0x18
    OCCloudKitStoreMonitor *storeMonitor = [_storeMonitor retain];
    // x23
    CKDatabaseScope databaseScope = _mirroringOptions.databaseScope;
    
    if ((databaseScope == CKDatabaseScopePublic) || (databaseScope == CKDatabaseScopePrivate)) {
        /*
         __51-[PFCloudKitSetupAssistant _createZoneIfNecessary:]_block_invoke
         storeMonitor = sp + 0x40
         self = sp + 0x48
         flag_1 = sp + 0x50
         _succeed = sp + 0x58
         _error = sp + 0x60
         databaseScope = sp + 0x68
         */
        [storeMonitor performBlock:^{
            abort();
        }];
    } else {
        _succeed = YES;
    }
    
    if (!_succeed) {
        *error = [[_error retain] autorelease];
        [storeMonitor release];
        [_error release];
        return NO;
    }
    
    if (flag_1) {
        [storeMonitor release];
        return YES;
    }
    
    // <+5080>
    _succeed = NO;
    
    switch (databaseScope) {
        case CKDatabaseScopeShared: {
            // <+5816>
            _succeed = YES;
            // <+5008>
            break;
        }
        case CKDatabaseScopePrivate: {
            // <+5104>
            // x23
            CKRecordZoneID *recordZoneID = [OCCloudKitSerializer defaultRecordZoneIDForDatabaseScope:CKDatabaseScopePrivate];
            // original : getCloudKitCKRecordZoneClass
            // x24
            CKRecordZone *recordZone = [[CKRecordZone alloc] initWithZoneID:recordZoneID];
            _succeed = [self _saveZone:recordZone error:&_error];
            
            if (!_succeed) {
                // <+6476>
                // original : getCloudKitCKErrorDomain
                if ([_error.domain isEqualToString:CKErrorDomain]) {
                    if (_error.code == 112) {
                        // <+6540>
                        // sp, #0xe0
                        NSError * _Nullable __error = nil;
                        _succeed = [self _deleteZone:recordZone error:&__error];
                        if (!_succeed) {
                            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@ unable to recover from error: %@\nEncountered subsequent error: %@", __func__, __LINE__, self, _error, __error);
                            *error = [[_error retain] autorelease];
                        } else {
                            _succeed = [self _saveZone:recordZone error:&__error];
                            if (!_succeed) {
                                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@ unable to recover from error: %@\nEncountered subsequent error: %@", __func__, __LINE__, self, _error, __error);
                                *error = [[_error retain] autorelease];
                            }
                        }
                    } else {
                        // <+8300>
                        if (_error.code == CKErrorPartialFailure) {
                            // x25
                            NSDictionary<NSErrorUserInfoKey, id> *userInfo = _error.userInfo;
                            // original : getCloudKitCKPartialErrorsByItemIDKey
                            // x25
                            NSDictionary<CKRecordZoneID *, NSError *> *partialErrorsByItemID = [userInfo objectForKey:CKPartialErrorsByItemIDKey];
                            // x25
                            NSError * _Nullable partialError = [partialErrorsByItemID objectForKey:recordZone.zoneID];
                            
                            // original : getCloudKitCKErrorDomain
                            if (([partialError.domain isEqualToString:CKErrorDomain]) && (partialError.code == CKErrorServerRecordChanged)) {
                                // sp, #0xe0
                                NSError * _Nullable __error = nil;
                                _succeed = [self _deleteZone:recordZone error:&__error];
                                if (!_succeed) {
                                    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@ unable to recover from error: %@\nEncountered subsequent error: %@", __func__, __LINE__, self, _error, __error);
                                    *error = [[_error retain] autorelease];
                                }
                            } else {
                                *error = [[_error retain] autorelease];
                            }
                        } else {
                            *error = [[_error retain] autorelease];
                        }
                    }
                } else {
                    // <+8456>
                    _succeed = NO;
                    *error = [[_error retain] autorelease];
                }
            }
            
            [recordZone release];
            [recordZoneID release];
            break;
        }
        default: {
            // <+5828>
            // x22
            CKRecordZoneID *recordZoneID = [OCCloudKitSerializer defaultRecordZoneIDForDatabaseScope:databaseScope];
            // original : getCloudKitCKRecordZoneClass
            // x24
            CKRecordZone *recordZone = [[CKRecordZone alloc] initWithZoneID:recordZoneID];
            // <+5872>
            _succeed = [self _checkIfZoneExists:recordZone error:&_error];
            // <+5008>
            [recordZone release];
            if (_error != nil) {
                *error = _error;
            }
            break;
        }
    }
    
    [storeMonitor release];
    return _succeed;
}

- (BOOL)_checkIfZoneExists:(CKRecordZone *)recordZone error:(NSError * _Nullable *)error {
    // inlined from -[PFCloudKitSetupAssistant _initializeCloudKitForObservedStore:andNoteMetadataInitialization:] <+5872>~<+7936>
    /*
     recordZone = x24
     */
    // x29 - 0xb0
    __block BOOL _succeed = NO; // 나중에 0x1 넣어주는듯?
    // x29 - 0xe0
    __block NSError * _Nullable _error = nil;
    // x26
    CKDatabaseScope databaseScope = _mirroringOptions.databaseScope;
    // x23
    dispatch_semaphore_t cloudKitSemaphore = _cloudKitSemaphore;
    
    // original : getCloudKitCKFetchRecordZonesOperationClass
    // x25
    CKFetchRecordZonesOperation *operation = [[CKFetchRecordZonesOperation alloc] initWithRecordZoneIDs:@[recordZone.zoneID]];
    [_setupRequest.options applyToOperation:operation];
    
    // x29 - 0x100
    __block NSDictionary<CKRecordZoneID *,CKRecordZone *> * _Nullable recordZonesByZoneID = nil;
    
    /*
     __53-[PFCloudKitSetupAssistant _checkIfZoneExists:error:]_block_invoke
     recordZone = sp + 0x170
     cloudKitSemaphore = sp + 0x178
     recordZonesByZoneID = sp + 0x180
     databaseScope = sp + 0x188
     _error = sp + 0x190
     _succeed = sp + 0x198
     */
    operation.fetchRecordZonesCompletionBlock = ^(NSDictionary<CKRecordZoneID *,CKRecordZone *> * _Nullable recordZonesByZoneID, NSError * _Nullable operationError) {
        abort();
    };
    
    [_database addOperation:operation];
    dispatch_semaphore_wait(cloudKitSemaphore, DISPATCH_TIME_FOREVER);
    
    if (!_succeed) {
        // original : getCloudKitCKErrorDomain
        if ((databaseScope == CKDatabaseScopePublic) && (_error.code == CKErrorNotAuthenticated) && ([_error.domain isEqualToString:CKErrorDomain])) {
            // <+6924>
            // original : getCloudKitCKRecordZoneDefaultName
            if (![recordZone.zoneID.zoneName isEqualToString:CKRecordZoneDefaultName]) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Custom zones aren't supported yet with the public database.\n");
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Custom zones aren't supported yet with the public database.\n");
            }
            // <+7088>
            _succeed = YES;
            [_error release];
            _error = nil;
            // x26
            OCCloudKitStoreMonitor *storeMonitor = [_storeMonitor retain];
            
            /*
             __53-[PFCloudKitSetupAssistant _checkIfZoneExists:error:]_block_invoke.67
             storeMonitor = sp + 0x100
             recordZone = sp + 0x108
             _succeed = sp + 0x110
             _error = sp + 0x118
             1 = sp + 0x120
             */
            [storeMonitor performBlock:^{
                abort();
            }];
            
            [storeMonitor release];
            [operation release];
            [_error release];
            _error = nil;
            return YES;
        } else {
            // <+7204>
            [operation release];
            
            if (_error == nil) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            } else {
                if (error != NULL) *error = [[_error retain] autorelease];
            }
            
            [_error release];
            return NO;
        }
    }
    
    // <+6144>
    // x22
    OCCloudKitStoreMonitor *storeMonitor = [_storeMonitor retain];
    
    /*
     __53-[PFCloudKitSetupAssistant _checkIfZoneExists:error:]_block_invoke.66
     storeMonitor = sp + 0x100
     recordZone = sp + 0x108
     recordZonesByZoneID = sp + 0x110
     _succeed = sp + 0x118
     _error = sp + 0x120
     */
    [storeMonitor performBlock:^{
        abort();
    }];
    
    [storeMonitor release];
    [operation release];
    [_error release];
    _error = nil;
    return YES;
}

- (BOOL)_setupDatabaseSubscriptionIfNecessary:(NSError * _Nullable *)error {
    // inlined from -[PFCloudKitSetupAssistant _initializeCloudKitForObservedStore:andNoteMetadataInitialization:] <+5284>~<+7936>
    // sp, #0x90
    __block BOOL _succeed = YES;
    // x29 - 0xe0
    __block NSError * _Nullable _error = nil;
    // x29 - 0x100
    __block BOOL databaseHasSubscription = NO;
    // sp + 0x1b0
    __block BOOL metadataHasSubscription = NO;
    // x21
    CKDatabaseScope databaseScope = _mirroringOptions.databaseScope;
    
    if (databaseScope == CKDatabaseScopePublic) {
        // <+7876>
        return YES;
    }
    
    [self beginActivityForPhase:5];
    // <+5392>
    // x22
    OCCloudKitStoreMonitor *storeMonitor = [_storeMonitor retain];
    
    if (databaseScope == CKDatabaseScopeShared) {
        // <+5676>
        /*
         __66-[PFCloudKitSetupAssistant _setupDatabaseSubscriptionIfNecessary:]_block_invoke_3
         storeMonitor = sp + 0x170
         databaseHasSubscription = sp + 0x178
         _succeed = sp + 0x180
         _error = sp + 0x188
         3 = sp + 0x190
         */
        [storeMonitor performBlock:^{
            abort();
        }];
        // <+5752>
    } else if (databaseScope == CKDatabaseScopePrivate) {
        // <+5432>
        // x24
        CKRecordZoneID *recordZoneID = [OCCloudKitSerializer defaultRecordZoneIDForDatabaseScope:CKDatabaseScopePrivate];
        
        /*
         __66-[PFCloudKitSetupAssistant _setupDatabaseSubscriptionIfNecessary:]_block_invoke
         storeMonitor = sp + 0x170
         recordZoneID = sp + 0x178
         metadataHasSubscription (sp + 0x1b0) DatabaseWithScope
         databaseHasSubscription = sp + 0x188
         _succeed = sp + 0x190
         _error = sp + 0x198
         2 = sp + 0x1a0
         */
        [storeMonitor performBlock:^{
            abort();
        }];
        
        [recordZoneID release];
    } else {
        // <+5752>
    }
    
    // <+5752>
    [storeMonitor release];
    
    if (!_succeed) {
        // <+7780>
        [self endActivityForPhase:5 withError:_error];
        
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) *error = [[_error retain] autorelease];
        }
        
        [_error release];
        _error = nil;
        
        return NO;
    }
    
    // <+5772>
    // x22
    CKSubscriptionID subscriptionID;
    switch (_mirroringOptions.databaseScope) {
        case CKDatabaseScopePublic:
            // <+6612>
            subscriptionID = [OCSPIResolver PFPublicDatabaseSubscriptionID];
            break;
        case CKDatabaseScopePrivate:
            // <+6600>
            subscriptionID = [OCSPIResolver PFPrivateDatabaseSubscriptionID];
            break;
        case CKDatabaseScopeShared:
            // <+5804>
            subscriptionID = [OCSPIResolver PFSharedDatabaseSubscriptionID];
            break;
        default:
            // <+6628>
            _succeed = NO;
            _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134400 userInfo:@{
                NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"CloudKit integration does not support the '%@' database scope.", CKDatabaseScopeString(_mirroringOptions.databaseScope)]
            }];
            *error = [_error autorelease];
            [self endActivityForPhase:5 withError:_error];
            return NO;
    }
    
    // <+6792>
    // original : getCloudKitCKDatabaseSubscriptionClass
    _databaseSubscription = [[CKDatabaseSubscription alloc] initWithSubscriptionID:subscriptionID];
    // x22
    CKNotificationInfo *notificationInfo = [[CKNotificationInfo alloc] init];
    notificationInfo.shouldSendContentAvailable = YES;
    _databaseSubscription.notificationInfo = notificationInfo;
    [notificationInfo release];
    
    [self endActivityForPhase:5 withError:_error];
    [_error release];
    _error = nil;
    return YES;
}

- (BOOL)_saveZone:(CKRecordZone *)recordZone error:(NSError * _Nullable *)error {
    abort();
}

- (BOOL)_deleteZone:(CKRecordZone *)recordZone error:(NSError * _Nullable *)error {
    abort();
}

@end
