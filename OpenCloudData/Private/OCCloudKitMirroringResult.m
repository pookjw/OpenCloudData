//
//  OCCloudKitMirroringResult.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import "OpenCloudData/Private/OCCloudKitMirroringResult.h"
#import "OpenCloudData/Private/Request/OCCloudKitMirroringRequest.h"
#import "OpenCloudData/Private/Log.h"

@implementation OCCloudKitMirroringResult

- (instancetype)initWithRequest:(__kindof OCCloudKitMirroringRequest *)request storeIdentifier:(NSString *)storeIdentifier success:(BOOL)success madeChanges:(BOOL)madeChanges error:(NSError *)error {
    if (self = [self init]) {
        _request = [request retain];
        _storeIdentifier = [storeIdentifier retain];
        _success = success;
        _madeChanges = madeChanges;
        
        NSError *rError = [error retain];
        _error = rError;
        
        if (success && (rError != nil)) {
            NSLog(@"initWithRequest passed an error (%@) on a succes condition", error);
            os_log_fault(_OCLogGetLogStream(0x11), "initWithRequest passed an error (%@) on a succes condition", error);
        } else if (!success && (rError == nil)) {
            NSLog(@"initWithRequest illegally passed nil instead of an error on a failure condition");
            os_log_fault(_OCLogGetLogStream(0x11), "initWithRequest illegally passed nil instead of an error on a failure condition");
        }
    }
    
    return self;
}

- (void)dealloc {
    [_request release];
    [_storeIdentifier release];
    [_error release];
    [super dealloc];
}

- (NSString *)description {
    NSMutableString *description = [super.description mutableCopy];
    [description appendFormat:@" storeIdentifier: %@ success: %d madeChanges: %d error: %@", _storeIdentifier, _success, _madeChanges, _error];
    return [description autorelease];
}

@end
