//
//  OCCloudKitMirroringExportProgressRequest.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/14/25.
//

#import "OpenCloudData/Private/Request/OCCloudKitMirroringRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitMirroringExportProgressRequest : OCCloudKitMirroringRequest {
    NSSet<NSManagedObjectID *> *_objectIDsToFetch; // 0x50
}
@property (copy, nonatomic, null_resettable) NSSet<NSManagedObjectID *> *objectIDsToFetch;
@end

NS_ASSUME_NONNULL_END
