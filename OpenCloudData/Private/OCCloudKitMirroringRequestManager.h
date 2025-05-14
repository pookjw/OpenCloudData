//
//  OCCloudKitMirroringRequestManager.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/22/25.
//

#import <OpenCloudData/OCCloudKitMirroringRequest.h>
#import <OpenCloudData/OCCloudKitMirroringDelegateSetupRequest.h>
#import <OpenCloudData/OCCloudKitMirroringDelegateResetRequest.h>
#import <OpenCloudData/OCCloudKitMirroringInitializeSchemaRequest.h>
#import <OpenCloudData/OCCloudKitMirroringFetchRecordsRequest.h>
#import <OpenCloudData/OCCloudKitMirroringImportRequest.h>
#import <OpenCloudData/OCCloudKitMirroringExportRequest.h>
#import <OpenCloudData/OCCloudKitMirroringResetZoneRequest.h>
#import <OpenCloudData/OCCloudKitMirroringResetMetadataRequest.h>
#import <OpenCloudData/OCCloudKitMirroringDelegateSerializationRequest.h>
#import <OpenCloudData/OCCloudKitMirroringExportProgressRequest.h>
#import <OpenCloudData/OCCloudKitMirroringAcceptShareInvitationsRequest.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCCloudKitMirroringRequestManager : NSObject {
    OCCloudKitMirroringImportRequest *_pendingImportRequest; // 0x08
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
