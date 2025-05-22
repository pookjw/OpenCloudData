//
//  OCCloudKitMirroringResetMetadataRequest.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/14/25.
//

#import "OpenCloudData/Private/Request/OCCloudKitMirroringRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitMirroringResetMetadataRequest : OCCloudKitMirroringRequest {
    NSSet<NSManagedObjectID *> *_objectIDsToReset; // 0x50
}
@property (copy, nonatomic) NSSet<NSManagedObjectID *> *objectIDsToReset;
@end

NS_ASSUME_NONNULL_END
