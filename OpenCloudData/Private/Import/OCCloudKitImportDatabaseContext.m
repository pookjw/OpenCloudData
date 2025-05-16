//
//  OCCloudKitImportDatabaseContext.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/15/25.
//

#import <OpenCloudData/OCCloudKitImportDatabaseContext.h>

@implementation OCCloudKitImportDatabaseContext

- (instancetype)init {
    if (self = [super init]) {
        _changedRecordZoneIDs = [[NSMutableSet alloc] init];
        _deletedRecordZoneIDs = [[NSMutableSet alloc] init];
        _purgedRecordZoneIDs = [[NSMutableSet alloc] init];
        _userResetEncryptedDataZoneIDs = [[NSMutableSet alloc] init];
        _updatedChangeToken = nil;
    }
    
    return self;
}

- (void)dealloc {
    [_changedRecordZoneIDs release];
    _changedRecordZoneIDs = nil;
    
    [_deletedRecordZoneIDs release];
    _deletedRecordZoneIDs = nil;
    
    [_purgedRecordZoneIDs release];
    _purgedRecordZoneIDs = nil;
    
    [_userResetEncryptedDataZoneIDs release];
    _userResetEncryptedDataZoneIDs = nil;
    
    [_updatedChangeToken release];
    _updatedChangeToken = nil;
    
    [super dealloc];
}

- (NSString *)description {
    // self = x19
    // x20
    NSMutableString *result = [[NSMutableString alloc] initWithString:[super description]];
    
    {
        id token = _updatedChangeToken;
        if (token == nil) token = [NSNull null];
        [result appendFormat:@" {\nToken: %@", token];
    }
    
    if (_changedRecordZoneIDs.count > 0) {
        [result appendFormat:@"\nChanged:\n%@", _changedRecordZoneIDs];
    }
    if (_deletedRecordZoneIDs.count > 0) {
        [result appendFormat:@"\nDeleted:\n%@", _deletedRecordZoneIDs];
    }
    if (_purgedRecordZoneIDs.count > 0) {
        [result appendFormat:@"\nPurged:\n%@", _purgedRecordZoneIDs];
    }
    if (_userResetEncryptedDataZoneIDs.count > 0) {
        [result appendFormat:@"\nReset:\n%@", _userResetEncryptedDataZoneIDs];
    }
    
    [result appendString:@"\n}"];
    
    return [result autorelease];
}

- (BOOL)hasWorkToDo {
    return (_changedRecordZoneIDs.count > 0) || (_purgedRecordZoneIDs.count > 0);
}

@end
