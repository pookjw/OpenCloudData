//
//  OCCloudKitMirroringFetchRecordsRequest.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/14/25.
//

#import "OpenCloudData/Private/Request/OCCloudKitMirroringImportRequest.h"

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCCloudKitMirroringFetchRecordsRequest : OCCloudKitMirroringImportRequest {
    NSArray<NSManagedObjectID *> *_objectIDsToFetch; // 0x50
    NSDictionary<NSString *, NSArray<NSAttributeDescription *> *> *_entityNameToAttributesToFetch; // 0x58
    NSDictionary *_entityNameToAttributeNamesToFetch; // 0x60
    BOOL _editable; // 0x68
    NSUInteger _perOperationObjectThreshold; // 0x70
}
@property (copy, nonatomic, readonly) NSDictionary<NSString *, NSArray<NSAttributeDescription *> *>* entityNameToAttributesToFetch;
// copy인지 검증
@property (retain, nonatomic, readonly, direct) NSArray<NSManagedObjectID *> *objectIDsToFetch;
@property (assign, nonatomic, readonly, direct) NSUInteger perOperationObjectThreshold;
@end

NS_ASSUME_NONNULL_END
