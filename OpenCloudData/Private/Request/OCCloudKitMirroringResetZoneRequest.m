//
//  OCCloudKitMirroringResetZoneRequest.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/14/25.
//

#import "OpenCloudData/Private/Request/OCCloudKitMirroringResetZoneRequest.h"

@implementation OCCloudKitMirroringResetZoneRequest

- (instancetype)initWithOptions:(OCCloudKitMirroringRequestOptions *)options completionBlock:(void (^)(OCCloudKitMirroringResult * _Nonnull))requestCompletionBlock {
    if (self = [super initWithOptions:options completionBlock:requestCompletionBlock]) {
        // original : getCloudKitCKRecordZoneIDClass, getCloudKitCKCurrentUserDefaultName
        // x20
        CKRecordZoneID *zoneID = [[CKRecordZoneID alloc] initWithZoneName:@"com.apple.coredata.cloudkit.zone" ownerName:CKCurrentUserDefaultName];
        _recordZoneIDsToReset = [[NSArray alloc] initWithObjects:zoneID, nil];
    }
    
    return self;
}

- (void)dealloc {
    [_recordZoneIDsToReset release];
    [super dealloc];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    OCCloudKitMirroringResetZoneRequest *copy = [super copyWithZone:zone];
    copy->_recordZoneIDsToReset = [_recordZoneIDsToReset retain];
    return copy;
}

@end
