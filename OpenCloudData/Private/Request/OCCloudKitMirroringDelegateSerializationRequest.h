//
//  OCCloudKitMirroringDelegateSerializationRequest.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/14/25.
//

#import "OpenCloudData/Private/Request/OCCloudKitMirroringRequest.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, OCCloudKitMirroringDelegateSerializationRequestResultType) {
    OCCloudKitMirroringDelegateSerializationRequestResultTypeRecordIDs = 0,
    OCCloudKitMirroringDelegateSerializationRequestResultTypeRecords = 1
};

@interface OCCloudKitMirroringDelegateSerializationRequest : OCCloudKitMirroringRequest {
    OCCloudKitMirroringDelegateSerializationRequestResultType _resultType; // 0x50
    NSSet<NSManagedObjectID *> *_objectIDsToSerialize; // 0x58
}
@property (assign, nonatomic) OCCloudKitMirroringDelegateSerializationRequestResultType resultType;
@property (copy, nonatomic, null_resettable) NSSet<NSManagedObjectID *> *objectIDsToSerialize;
+ (NSString * _Nullable)stringForResultType:(OCCloudKitMirroringDelegateSerializationRequestResultType)resultType __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
