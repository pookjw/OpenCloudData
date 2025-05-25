//
//  OCCloudKitMirroringAcceptShareInvitationsRequest.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/14/25.
//

#import "OpenCloudData/Private/Request/OCCloudKitMirroringRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitMirroringAcceptShareInvitationsRequest : OCCloudKitMirroringRequest {
    NSArray<NSURL *> *_shareURLsToAccept; // 0x50
    NSArray *_shareMetadatasToAccept; // 0x58
}
@property (copy, nonatomic, direct) NSArray<NSURL *> *shareURLsToAccept;
@property (copy, nonatomic, direct) NSArray *shareMetadatasToAccept;
@end

NS_ASSUME_NONNULL_END
