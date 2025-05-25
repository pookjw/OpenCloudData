//
//  OCCloudKitMirroringRequestManager.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/22/25.
//

#import "OpenCloudData/Private/OCCloudKitMirroringRequestManager.h"
#import "OpenCloudData/Private/Log.h"

@implementation OCCloudKitMirroringRequestManager

- (void)dealloc {
    [_pendingImportRequest release];
    _pendingImportRequest = nil;
    
    [_pendingExportRequest release];
    _pendingExportRequest = nil;
    
    [_pendingSetupRequest release];
    _pendingSetupRequest = nil;
    
    [_pendingDelegateResetRequest release];
    _pendingDelegateResetRequest = nil;
    
    [_pendingResetRequest release];
    _pendingResetRequest = nil;
    
    [_pendingFetchRecordsRequest release];
    _pendingFetchRecordsRequest = nil;
    
    [_pendingResetMetadataRequest release];
    _pendingResetMetadataRequest = nil;
    
    [_pendingSerializationRequest release];
    _pendingSerializationRequest = nil;
    
    [_pendingInitializeSchemaRequest release];
    _pendingInitializeSchemaRequest = nil;
    
    [_pendingExportProgressRequest release];
    _pendingExportProgressRequest = nil;
    
    [_pendingAcceptShareInvitationRequest release];
    _pendingAcceptShareInvitationRequest = nil;
    
    [_activeRequest release];
    _activeRequest = nil;
    
    [super dealloc];
}

- (BOOL)enqueueRequest:(__kindof OCCloudKitMirroringRequest *)request error:(NSError * _Nullable *)error {
    /*
     self = x20
     request = x19
     error = x21
     */
    BOOL hasPendingRequest;
    if ([request isKindOfClass:[OCCloudKitMirroringDelegateSetupRequest class]]) {
        // <+84>
        if (_pendingSetupRequest != nil) {
            hasPendingRequest = YES;
            // <+188>
        } else {
            _pendingSetupRequest = [request retain];
            hasPendingRequest = NO;
            // <+540>
        }
    } else if ([request isKindOfClass:[OCCloudKitMirroringFetchRecordsRequest class]]) {
        // <+132>
        if (_pendingFetchRecordsRequest != nil) {
            hasPendingRequest = YES;
            // <+188>
        } else {
            _pendingFetchRecordsRequest = [request retain];
            hasPendingRequest = NO;
            // <+540>
        }
    } else if ([request isKindOfClass:[OCCloudKitMirroringImportRequest class]]) {
        // <+180>
        if (_pendingImportRequest != nil) {
            hasPendingRequest = YES;
            // <+188>
        } else {
            _pendingImportRequest = [request retain];
            hasPendingRequest = NO;
            // <+540>
        }
    } else if ([request isKindOfClass:[OCCloudKitMirroringExportRequest class]]) {
        // <+368>
        if (_pendingExportRequest == nil) {
            _pendingExportRequest = [request retain];
            hasPendingRequest = NO;
        } else {
            if (request == nil) {
                hasPendingRequest = YES;
                // <+188>
            } else {
                // <+380>
                [_pendingExportRequest addContainerBlock:request.requestCompletionBlock];
                hasPendingRequest = NO;
                // <+540>
            }
        }
    } else if ([request isKindOfClass:[OCCloudKitMirroringResetZoneRequest class]]) {
        // <+452>
        if (_pendingResetRequest != nil) {
            hasPendingRequest = YES;
            // <+188>
        } else {
            _pendingResetRequest = [request retain];
            hasPendingRequest = NO;
            // <+540>
        }
    } else if ([request isKindOfClass:[OCCloudKitMirroringResetMetadataRequest class]]) {
        // <+512>
        if (_pendingResetMetadataRequest != nil) {
            hasPendingRequest = YES;
            // <+188>
        } else {
            _pendingResetMetadataRequest = [request retain];
            hasPendingRequest = NO;
            // <+540>
        }
    } else if ([request isKindOfClass:[OCCloudKitMirroringDelegateResetRequest class]]) {
        // <+576>
        if (_pendingDelegateResetRequest != nil) {
            hasPendingRequest = YES;
            // <+188>
        } else {
            _pendingDelegateResetRequest = [request retain];
            hasPendingRequest = NO;
            // <+540>
        }
    } else if ([request isKindOfClass:[OCCloudKitMirroringDelegateSerializationRequest class]]) {
        // <+624>
        if (_pendingSerializationRequest != nil) {
            hasPendingRequest = YES;
            // <+188>
        } else {
            _pendingSerializationRequest = [request retain];
            hasPendingRequest = NO;
            // <+540>
        }
    } else if ([request isKindOfClass:[OCCloudKitMirroringInitializeSchemaRequest class]]) {
        // <+672>
        if (_pendingInitializeSchemaRequest != nil) {
            hasPendingRequest = YES;
            // <+188>
        } else {
            _pendingInitializeSchemaRequest = [request retain];
            hasPendingRequest = NO;
            // <+540>
        }
    } else if ([request isKindOfClass:[OCCloudKitMirroringExportProgressRequest class]]) {
        // <+720>
        if (_pendingExportProgressRequest != nil) {
            hasPendingRequest = YES;
            // <+188>
        } else {
            _pendingExportProgressRequest = [request retain];
            hasPendingRequest = NO;
            // <+540>
        }
    } else if ([request isKindOfClass:[OCCloudKitMirroringAcceptShareInvitationsRequest class]]) {
        // <+768>
        if (_pendingAcceptShareInvitationRequest == nil) {
            _pendingAcceptShareInvitationRequest = [request retain];
            hasPendingRequest = NO;
            // <+540>
        } else {
            if (!request.isContainerRequest) {
                hasPendingRequest = YES;
                // <+188>
            } else {
                // <+800>
                // x21
                NSMutableArray *shareURLsToAccept = [[NSMutableArray alloc] initWithArray:_pendingAcceptShareInvitationRequest.shareURLsToAccept];
                [shareURLsToAccept addObjectsFromArray:((OCCloudKitMirroringAcceptShareInvitationsRequest *)request).shareURLsToAccept];
                // x22
                NSMutableArray *shareMetadatasToAccept = [[NSMutableArray alloc] initWithArray:_pendingAcceptShareInvitationRequest.shareMetadatasToAccept];
                [shareMetadatasToAccept addObjectsFromArray:((OCCloudKitMirroringAcceptShareInvitationsRequest *)request).shareMetadatasToAccept];
                
                _pendingAcceptShareInvitationRequest.shareURLsToAccept = shareURLsToAccept;
                _pendingAcceptShareInvitationRequest.shareMetadatasToAccept = shareMetadatasToAccept;
                [_pendingAcceptShareInvitationRequest addContainerBlock:request.requestCompletionBlock];
                
                [shareMetadatasToAccept release];
                [shareURLsToAccept release];
                hasPendingRequest = NO;
                // <+540>
            }
        }
    } else {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Unknown request class: %@\n", request);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Unknown request class: %@\n", request);
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        return NO;
    }
    
    if (hasPendingRequest) {
        // <+188>
        NSError *_error = [NSError errorWithDomain:NSCocoaErrorDomain code:134417 userInfo:@{
            NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Request '%@' was cancelled because there is already a pending request of type '%@'.", request, NSStringFromClass([request class])]
        }];
        
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) {
                *error = _error;
            }
        }
        return NO;
    }
    
    return YES;
}

- (OCCloudKitMirroringRequest *)dequeueNextRequest {
    // self = x19
    OCCloudKitMirroringRequest * _Nullable activeRequest = _activeRequest;
    
    if (activeRequest != nil) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Dequeue called during an active request: %@\n", activeRequest);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Dequeue called during an active request: %@\n", activeRequest);
    }
    
    // 0x20 + 0x18 + 0x48
    
    // self = x21
    __kindof OCCloudKitMirroringRequest * _Nullable nextRequest;
    if (_pendingDelegateResetRequest != nil) {
        nextRequest = [_pendingDelegateResetRequest retain];
        [_pendingDelegateResetRequest release];
        _pendingDelegateResetRequest = nil;
    } else if (_pendingSetupRequest != nil) {
        nextRequest = [_pendingSetupRequest retain];
        [_pendingSetupRequest release];
        _pendingSetupRequest = nil;
    } else if (_pendingInitializeSchemaRequest != nil) {
        nextRequest = [_pendingInitializeSchemaRequest retain];
        [_pendingInitializeSchemaRequest release];
        _pendingInitializeSchemaRequest = nil;
    } else if (_pendingResetRequest != nil) {
        nextRequest = [_pendingResetRequest retain];
        [_pendingResetRequest release];
        _pendingResetRequest = nil;
    } else if (_pendingResetMetadataRequest != nil) {
        nextRequest = [_pendingResetMetadataRequest retain];
        [_pendingResetMetadataRequest release];
        _pendingResetMetadataRequest = nil;
    } else if (_pendingAcceptShareInvitationRequest != nil) {
        nextRequest = [_pendingAcceptShareInvitationRequest retain];
        [_pendingAcceptShareInvitationRequest release];
        _pendingAcceptShareInvitationRequest = nil;
    } else if (_pendingSerializationRequest != nil) {
        nextRequest = [_pendingSerializationRequest retain];
        [_pendingSerializationRequest release];
        _pendingSerializationRequest = nil;
    } else if (_pendingImportRequest != nil) {
        nextRequest = [_pendingImportRequest retain];
        [_pendingImportRequest release];
        _pendingImportRequest = nil;
    } else if (_pendingExportRequest != nil) {
        nextRequest = [_pendingExportRequest retain];
        [_pendingExportRequest release];
        _pendingExportRequest = nil;
    } else if (_pendingFetchRecordsRequest != nil) {
        nextRequest = [_pendingFetchRecordsRequest retain];
        [_pendingFetchRecordsRequest release];
        _pendingFetchRecordsRequest = nil;
    } else if (_pendingExportProgressRequest != nil) {
        nextRequest = [_pendingExportProgressRequest retain];
        [_pendingExportProgressRequest release];
        _pendingExportProgressRequest = nil;
    } else {
        nextRequest = nil;
    }
    
    if (nextRequest != nil) {
        _activeRequest = nextRequest;
    }
    
    return nextRequest;
}

@end
