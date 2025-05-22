//
//  OCCloudKitMirroringResetZoneRequest.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/14/25.
//

#import "OpenCloudData/Private/Request/OCCloudKitMirroringRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitMirroringResetZoneRequest : OCCloudKitMirroringRequest {
    NSArray<CKRecordZoneID *> *_recordZoneIDsToReset; // 0x50
}
@end

NS_ASSUME_NONNULL_END
