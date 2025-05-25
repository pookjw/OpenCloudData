//
//  OCCloudKitMirroringRequestManager.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/22/25.
//

#import "OpenCloudData/Private/Request/OCCloudKitMirroringRequest.h"
#import "OpenCloudData/Private/Request/OCCloudKitMirroringDelegateSetupRequest.h"
#import "OpenCloudData/Private/Request/OCCloudKitMirroringDelegateResetRequest.h"
#import "OpenCloudData/Private/Request/OCCloudKitMirroringInitializeSchemaRequest.h"
#import "OpenCloudData/Private/Request/OCCloudKitMirroringFetchRecordsRequest.h"
#import "OpenCloudData/Private/Request/OCCloudKitMirroringImportRequest.h"
#import "OpenCloudData/Private/Request/OCCloudKitMirroringExportRequest.h"
#import "OpenCloudData/Private/Request/OCCloudKitMirroringResetZoneRequest.h"
#import "OpenCloudData/Private/Request/OCCloudKitMirroringResetMetadataRequest.h"
#import "OpenCloudData/Private/Request/OCCloudKitMirroringDelegateSerializationRequest.h"
#import "OpenCloudData/Private/Request/OCCloudKitMirroringExportProgressRequest.h"
#import "OpenCloudData/Private/Request/OCCloudKitMirroringAcceptShareInvitationsRequest.h"

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCCloudKitMirroringRequestManager : NSObject {
    OCCloudKitMirroringImportRequest *_pendingImportRequest; // 0x8
    OCCloudKitMirroringExportRequest *_pendingExportRequest; // 0x10
    OCCloudKitMirroringDelegateSetupRequest *_pendingSetupRequest; // 0x18
    OCCloudKitMirroringDelegateResetRequest *_pendingDelegateResetRequest; // 0x20
    OCCloudKitMirroringResetZoneRequest *_pendingResetRequest; // 0x28
    OCCloudKitMirroringFetchRecordsRequest *_pendingFetchRecordsRequest; // 0x30
    OCCloudKitMirroringResetMetadataRequest *_pendingResetMetadataRequest; // 0x38
    OCCloudKitMirroringDelegateSerializationRequest *_pendingSerializationRequest; // 0x40
    OCCloudKitMirroringInitializeSchemaRequest *_pendingInitializeSchemaRequest; // 0x48
    OCCloudKitMirroringExportProgressRequest *_pendingExportProgressRequest; // 0x50
    OCCloudKitMirroringAcceptShareInvitationsRequest *_pendingAcceptShareInvitationRequest; // 0x58
    @package OCCloudKitMirroringRequest *_activeRequest; // 0x60
}
- (BOOL)enqueueRequest:(__kindof OCCloudKitMirroringRequest *)request error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
- (OCCloudKitMirroringRequest * _Nullable)dequeueNextRequest __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
