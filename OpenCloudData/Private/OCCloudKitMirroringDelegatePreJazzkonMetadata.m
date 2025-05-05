//
//  OCCloudKitMirroringDelegatePreJazzkonMetadata.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/3/25.
//

#import <OpenCloudData/OCCloudKitMirroringDelegatePreJazzkonMetadata.h>
#import <OpenCloudData/Log.h>

COREDATA_EXTERN NSString * const PFCloudKitServerChangeTokenKey;
COREDATA_EXTERN NSString * const NSCloudKitMirroringDelegateLastHistoryTokenKey;
COREDATA_EXTERN NSString * const NSCloudKitMirroringDelegateServerChangeTokensKey;

@implementation OCCloudKitMirroringDelegatePreJazzkonMetadata

+ (NSArray<NSString *> *)allDefaultsKeys {
    return @[
        @"NSCloudKitMirroringDelegateInitializedZoneDefaultsKey",
        @"NSCloudKitMirroringDelegateInitializedZoneSubscriptionDefaultsKey",
        @"NSCloudKitMirroringDelegateCKIdentityRecordNameDefaultsKey",
        @"NSCloudKitMirroringDelegateCheckedCKIdentityDefaultsKey",
        PFCloudKitServerChangeTokenKey,
        NSCloudKitMirroringDelegateLastHistoryTokenKey,
        NSCloudKitMirroringDelegateServerChangeTokensKey,
        @"NSCloudKitMirroringDelegateInitializedDatabaseSubscriptionKey"
    ];
}

- (instancetype)initWithStore:(NSPersistentStore *)store {
    if (self = [super init]) {
        _store = store;
    }
    return self;
}

- (void)dealloc {
    [_ckIdentityRecordName release];
    _ckIdentityRecordName = nil;
    
    [_keyToPreviousServerChangeToken release];
    _keyToPreviousServerChangeToken = nil;
    
    [_lastHistoryToken release];
    _lastHistoryToken = nil;
    
    [super dealloc];
}

- (BOOL)isEqual:(id)other {
    /*
     self = x22
     other = x21
     */
    if (other == self) {
        return YES;
    } else if (![other isKindOfClass:[OCCloudKitMirroringDelegatePreJazzkonMetadata class]]) {
        return [super isEqual:other];
    }
    // x21
    OCCloudKitMirroringDelegatePreJazzkonMetadata *casted = (OCCloudKitMirroringDelegatePreJazzkonMetadata *)other;
    
    // x19
    NSPersistentStore * _Nullable store_1 = _store;
    // x20
    NSPersistentStore * _Nullable store_2 = casted->_store;
    
    if (_loaded != casted->_loaded) return NO;
    if (_hasInitializedZone != casted->_hasInitializedZone) return NO;
    if (_hasCheckedCKIdentity != casted->_hasCheckedCKIdentity) return NO;
    if (_hasInitializedZoneSubscription != casted->_hasInitializedZoneSubscription) return NO;
    if (_hasInitializedDatabaseSubscription != casted->_hasInitializedDatabaseSubscription) return NO;
    
    NSString *identifier_1 = store_1.identifier;
    NSString *identifier_2 = store_2.identifier;
    if (identifier_1 != identifier_2) {
        if ((identifier_1 == nil) || (identifier_2 == nil)) return NO;
        if (![identifier_1 isEqualToString:identifier_2]) return NO;
    }
    
    NSString *_ckIdentityRecordName_1 = _ckIdentityRecordName;
    NSString *_ckIdentityRecordName_2 = casted->_ckIdentityRecordName;
    if (_ckIdentityRecordName_1 != _ckIdentityRecordName_2) {
        if ((_ckIdentityRecordName_1 == nil) || (_ckIdentityRecordName_2 == nil)) return NO;
        if (![_ckIdentityRecordName_1 isEqualToString:_ckIdentityRecordName_2]) return NO;
    }
    
    NSDictionary *_keyToPreviousServerChangeToken_1 = _keyToPreviousServerChangeToken;
    NSDictionary *_keyToPreviousServerChangeToken_2 = casted->_keyToPreviousServerChangeToken;
    if (_keyToPreviousServerChangeToken_1 != _keyToPreviousServerChangeToken_2) {
        if ((_keyToPreviousServerChangeToken_1 == nil) || (_keyToPreviousServerChangeToken_2 == nil)) return NO;
        if (![_keyToPreviousServerChangeToken_1 isEqualToDictionary:_keyToPreviousServerChangeToken_2]) return NO;
    }
    
    NSPersistentHistoryToken *_lastHistoryToken_1 = _lastHistoryToken;
    NSPersistentHistoryToken *_lastHistoryToken_2 = casted->_lastHistoryToken;
    if (_lastHistoryToken_1 != _lastHistoryToken_2) {
        if (![_lastHistoryToken_1 isEqual:_lastHistoryToken_2]) return NO;
    }
    
    return YES;
}

- (NSString *)description {
    /*
     self = x19
     */
    // x20
    NSMutableString *result = [[NSMutableString alloc] initWithFormat:@"<%@: %p; %@", NSStringFromClass([self class]), self, _loaded ? @"loaded" : @"not-loaded"];
    
    if (!_hasChanges) {
        [result appendFormat:@",changed:%d", _hasChanges];
        [result appendFormat:@",initZone:%d", _hasInitializedZone];
        [result appendFormat:@",initZoneSub:%d", _hasInitializedZoneSubscription];
        [result appendFormat:@",initDatabaseSub:%d", _hasInitializedDatabaseSubscription];
        [result appendFormat:@",identity:%@", _ckIdentityRecordName];
        [result appendFormat:@",checkedIdentity:%d", _hasCheckedCKIdentity];
        
        [result appendString:@",changeTokens:"];
        if (_keyToPreviousServerChangeToken.count == 0) {
            [result appendString:@"empty"];
        } else {
            /*
             __60-[NSCloudKitMirroringDelegatePreJazzkonMetadata description]_block_invoke
             x20 = sp + 0x38
             */
            [_keyToPreviousServerChangeToken enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [result appendFormat:@",%@:%@", key, obj];
            }];
        }
        
        [result appendFormat:@",historyToken:%@", _lastHistoryToken];
    }
    
    [result appendString:@">"];
    return [result autorelease];
}

- (BOOL)load:(NSError * _Nullable * _Nullable)error {
    /*
     self = x21
     error = sp + 0x18
     */
    @try {
        if (_loaded) return YES;
        
        // sp + 0x30
        NSError * _Nullable _error = nil;
        // sp + 0x3c
        BOOL _succeed = YES;
        
        // x19 / sp + 0x20
        NSPersistentStore * _Nullable store = _store;
        // sp + 0x28
        // 안 씀
        NSPersistentStoreCoordinator *persistentStoreCoordinator = [store.persistentStoreCoordinator retain];
        
        @autoreleasepool {
            // x24
            NSDictionary<NSString *, id> *metadata = store.metadata;
            _hasInitializedZone = ((NSNumber *)[metadata objectForKey:@"NSCloudKitMirroringDelegateInitializedZoneDefaultsKey"]).boolValue;
            _hasInitializedZoneSubscription = ((NSNumber *)[metadata objectForKey:@"NSCloudKitMirroringDelegateInitializedZoneSubscriptionDefaultsKey"]).boolValue;
            _hasInitializedDatabaseSubscription = ((NSNumber *)[metadata objectForKey:@"NSCloudKitMirroringDelegateInitializedDatabaseSubscriptionKey"]).boolValue;
            _ckIdentityRecordName = [[metadata objectForKey:@"NSCloudKitMirroringDelegateCKIdentityRecordNameDefaultsKey"] retain];
            _hasCheckedCKIdentity = ((NSNumber *)[metadata objectForKey:@"NSCloudKitMirroringDelegateCheckedCKIdentityDefaultsKey"]).boolValue;
            
            // x19
            NSData *serverChangeTokenData = [metadata objectForKey:PFCloudKitServerChangeTokenKey];
            // x26
            CKServerChangeToken * _Nullable token;
            if (serverChangeTokenData != nil) {
                // sp, #0x40
                NSError * _Nullable __error = nil;
                // original : getCloudKitCKServerChangeTokenClass
                // x26
                token = [NSKeyedUnarchiver unarchivedObjectOfClass:[CKServerChangeToken class] fromData:serverChangeTokenData error:&__error];
                
                if (token == nil) {
                    if ((__error.code == NSCoderValueNotFoundError) && ([__error.domain isEqualToString:NSCocoaErrorDomain])) {
                        _error = nil;
                        _succeed = YES;
                    } else {
                        NSString *string = [NSString stringWithFormat:@"Failed to deserialize '%@' out of the metadata for store: %@", PFCloudKitServerChangeTokenKey, store];
                        // x27
                        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
                        [userInfo setObject:string forKey:NSLocalizedFailureReasonErrorKey];
                        if (__error != nil) {
                            [userInfo setObject:__error forKey:NSUnderlyingErrorKey];
                        }
                        // x19
                        NSError *___error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134402 userInfo:userInfo];
                        [userInfo release];
                        
                        _error = ___error;
                        _succeed = NO;
                    }
                }
            } else {
                token = nil;
                _error = nil;
                _succeed = YES;
            }
            
            // <+584>
            // x28
            NSData *serverChangeTokensData = [metadata objectForKey:NSCloudKitMirroringDelegateServerChangeTokensKey];
            
            if (serverChangeTokensData == nil) {
                // <+744>
                if (token == nil) {
                    // <+976>
                    _keyToPreviousServerChangeToken = [[NSDictionary alloc] init];
                } else {
                    // getCloudKitCKCurrentUserDefaultName
                    // x19
                    NSString *key = [self _keyForZoneName:@"com.apple.coredata.cloudkit.zone" owner:CKCurrentUserDefaultName databaseScope:CKDatabaseScopePrivate];
                    _keyToPreviousServerChangeToken = [[NSDictionary alloc] initWithObjectsAndKeys:token, key, nil];
                }
            } else {
                // <+616>
                // sp, #0x40
                NSError * _Nullable __error = nil;
                
                // original : getCloudKitCKServerChangeTokenClass
                NSSet<Class> *classes = [NSSet setWithObjects:[NSDictionary class], [NSString class], [CKServerChangeToken class], nil];
                NSDictionary<NSString *, CKServerChangeToken *> * _Nullable dictionary = [NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:serverChangeTokensData error:&__error];
                
                if (dictionary == nil) {
                    // <+816>
                    NSString *string = [NSString stringWithFormat:@"Failed to deserialize '%@' out of the metadata for store: %@", NSCloudKitMirroringDelegateServerChangeTokensKey, store];
                    // x26
                    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
                    [userInfo setObject:string forKey:NSLocalizedFailureReasonErrorKey];
                    if (__error != nil) {
                        [userInfo setObject:__error forKey:NSUnderlyingErrorKey];
                    }
                    _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134402 userInfo:userInfo];
#warning TODO: Error Leak
                    [userInfo release];
                    _succeed = NO;
                } else {
                    // +728>
                    _keyToPreviousServerChangeToken = [dictionary retain];
                }
            }
            
            // <+992>
            // x19
            NSData *lastHistoryTokenData = [metadata objectForKey:NSCloudKitMirroringDelegateLastHistoryTokenKey];
            
            if (lastHistoryTokenData != nil) {
                // <+1024>
                // sp, #0x40
                NSError * _Nullable __error = nil;
                NSPersistentHistoryToken * _Nullable token = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSPersistentHistoryToken class] fromData:lastHistoryTokenData error:&__error];
                
                if (token == nil) {
                    NSString *string = [NSString stringWithFormat:@"Failed to deserialize '%@' out of the metadata for store: %@", NSCloudKitMirroringDelegateLastHistoryTokenKey, store];
                    // x23
                    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
                    [userInfo setObject:string forKey:NSLocalizedFailureReasonErrorKey];
                    if (__error != nil) {
                        [userInfo setObject:__error forKey:NSUnderlyingErrorKey];
                    }
                    _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134402 userInfo:userInfo];
#warning TODO: Error Leak
                    [userInfo release];
                    _succeed = NO;
                } else {
                    _lastHistoryToken = [token retain];
                }
            }
        }
        
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
            [persistentStoreCoordinator release];
            _loaded = YES;
            return _succeed;
        }
        
        [_error release];
        [persistentStoreCoordinator release];
        _loaded = YES;
        return YES;
    } @catch (NSException *exception) {
        NSError * _error = [NSError errorWithDomain:NSCocoaErrorDomain code:134402 userInfo:@{@"NSUnderlyingException": ((exception == nil) ? [NSNull null] : exception)}];
        if (error != NULL) *error = _error;
        _loaded = YES;
        return NO;
    }
}

- (CKServerChangeToken *)changeTokenForDatabaseScope:(CKDatabaseScope)databaseScope {
    if (!_loaded) {
        // original : NSStringFromSelector(@selector(changeTokenForDatabaseScope:))
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@:%@ called before load.", [OCCloudKitMirroringDelegatePreJazzkonMetadata class], @"changeTokenForDatabaseScope:"] userInfo:nil];
    }
    // x19
    NSDictionary<NSString *, CKServerChangeToken *> *keyToPreviousServerChangeToken = _keyToPreviousServerChangeToken;
    NSString *key = [self _keyForDatabaseScope:databaseScope];
    CKServerChangeToken *token = [keyToPreviousServerChangeToken objectForKey:key];
    return token;
}

- (BOOL)hasInitializedDatabaseSubscription {
    if (!_loaded) {
        // original : NSStringFromSelector(@selector(hasInitializedDatabaseSubscription))
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@:%@ called before load.", [OCCloudKitMirroringDelegatePreJazzkonMetadata class], @"hasInitializedDatabaseSubscription"] userInfo:nil];
    }
    
    return _hasInitializedDatabaseSubscription;
}

- (CKServerChangeToken *)changeTokenForZoneWithID:(CKRecordZoneID *)zoneID inDatabaseWithScope:(CKDatabaseScope)databaseScope {
    /*
     zoneID = x20
     databaseScope = x19
     */
    if (!_loaded) {
        // original : NSStringFromSelector(@selector(changeTokenForZoneWithID:inDatabaseWithScope:))
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@:%@ called before load.", [OCCloudKitMirroringDelegatePreJazzkonMetadata class], @"changeTokenForZoneWithID:inDatabaseWithScope:"] userInfo:nil];
    }
    
    // x21
    NSDictionary<NSString *, CKServerChangeToken *> *keyToPreviousServerChangeToken = _keyToPreviousServerChangeToken;
    NSString *key = [self _keyForZoneName:zoneID.zoneName owner:zoneID.ownerName databaseScope:databaseScope];
    return [keyToPreviousServerChangeToken objectForKey:key];
}

- (NSPersistentHistoryToken *)lastHistoryToken {
    if (!_loaded) {
        // original : NSStringFromSelector(@selector(lastHistoryToken))
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@:%@ called before load.", [OCCloudKitMirroringDelegatePreJazzkonMetadata class], @"lastHistoryToken"] userInfo:nil];
    }
    
    return _lastHistoryToken;
}

- (NSString *)ckIdentityRecordName {
    if (!_loaded) {
        // original : NSStringFromSelector(@selector(ckIdentityRecordName))
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@:%@ called before load.", [OCCloudKitMirroringDelegatePreJazzkonMetadata class], @"ckIdentityRecordName"] userInfo:nil];
    }
    
    return [[_ckIdentityRecordName retain] autorelease];
}

- (BOOL)hasCheckedCKIdentity {
    if (!_loaded) {
        // original : NSStringFromSelector(@selector(hasCheckedCKIdentity))
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@:%@ called before load.", [OCCloudKitMirroringDelegatePreJazzkonMetadata class], @"hasCheckedCKIdentity"] userInfo:nil];
    }
    
    return _hasCheckedCKIdentity;
}

- (NSString *)_keyForZoneName:(NSString *)zoneName owner:(NSString *)owner databaseScope:(CKDatabaseScope)databaseScope __attribute__((objc_direct)) {
    NSMutableString *string = [[NSMutableString alloc] initWithString:[self _keyForDatabaseScope:databaseScope]];
    [string appendFormat:@".%@.%@", zoneName, owner];
    NSString *copy = [string copy];
    [string release];
    return [copy autorelease];
}

- (NSString *)_keyForDatabaseScope:(CKDatabaseScope)databaseScope __attribute__((objc_direct)) {
    switch (databaseScope) {
        case CKDatabaseScopePublic:
            return @"public";
        case CKDatabaseScopePrivate:
            return @"private";
        case CKDatabaseScopeShared:
            return @"shared";
        default:
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Unknown database scope: %lu", databaseScope] userInfo:nil];
    }
}

@end
