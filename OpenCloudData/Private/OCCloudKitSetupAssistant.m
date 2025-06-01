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
    // sp, #0x20
    __block BOOL _succeed = YES;
    // sp, #0xe0
    __block NSError * _Nullable _error = nil;
    
    [self beginActivityForPhase:1];
    
    OCCloudKitStoreMonitor *storeMonitor = _storeMonitor;
    /*
     __56-[PFCloudKitSetupAssistant _checkAndInitializeMetadata:]_block_invoke
     storeMonitor = sp + 0x170
     self = sp + 0x178
     _succeed = sp + 0x180
     _error = sp + 0x188
     */
    [storeMonitor performBlock:^{
        abort();
    }];
    
    [self endActivityForPhase:1 withError:_error];
    
    if (!_succeed) {
        // <+276>
        NSError * _Nullable __error = [[_error retain] autorelease];
        
        if (__error == nil) {
            // <+900>
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) *error = __error;
        }
        
        return NO;
    }
    
    // <+300>
    [_error release];
    _error = nil;
    
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
    // <+1936>
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
    
    
    abort();
}

- (void)beginActivityForPhase:(NSUInteger)phase {
    abort();
}

- (void)endActivityForPhase:(NSUInteger)phase withError:(NSError *)error {
    abort();
}

- (BOOL)_initializeAssetStorageURLError:(NSError * _Nullable * _Nullable)error {
    // inlined from -[PFCloudKitSetupAssistant _initializeCloudKitForObservedStore:andNoteMetadataInitialization:] <+372>~<+1196>
    [self beginActivityForPhase:6];
    
    // x29 - 0xe0
    __block BOOL _succeed = YES;
    // sp, #0xe0
    __block NSError * _Nullable _error = nil;
    // sp + 0x20
    NSURL * _Nullable largeBlobDirectoryURL = nil;
    
    /*
     __60-[PFCloudKitSetupAssistant _initializeAssetStorageURLError:]_block_invoke
     _storeMonitor = sp + 0x170
     largeBlobDirectoryURL = sp + 0x178
     _succeed = sp + 0x180
     _error = sp + 0x188
     */
    [_storeMonitor performBlock:^{
        abort();
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
     storeMonitor = sp + 0x100
     _error = sp + 0x108
     userIdentity = sp + 0x110
     _succeed = sp + 0x118
     */
    [storeMonitor performBlock:^{
        abort();
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
     monitorGroup = sp + 0x170
     self = sp + 0x178
     cloudKitSemaphore = sp + 0x180
     _succeed = sp + 0x188
     userIdentity = sp + 0x190
     _error = sp + 0x198
     useDeviceToDeviceEncryption = sp + 0x1a0
     */
    [container accountInfoWithCompletionHandler:^(CKAccountInfo * _Nullable accountInfo, NSError * _Nullable error) {
        abort();
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
            abort();
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
    
    // TODO: Error Handling
    
    // <+5008>
//    [self endActivityForPhase:4 withError:<#(NSError * _Nullable)#>]
    abort();
}

- (BOOL)_createZoneIfNecessary:(NSError * _Nullable *)error {
    // inlined from -[PFCloudKitSetupAssistant _initializeCloudKitForObservedStore:andNoteMetadataInitialization:] <+4880>~
    
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
        return YES;
    }
    
    // <+5080>
    _succeed = NO;
    
    abort();
}

@end
