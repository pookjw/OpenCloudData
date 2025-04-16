//
//  CKRecord+Private.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/15/25.
//

#import <CloudKit/CloudKit.h>
#import <OpenCloudData/CKEncryptedRecordValueStore.h>

NS_ASSUME_NONNULL_BEGIN

@interface CKRecord (Private)
@property (copy) CKEncryptedRecordValueStore *encryptedValueStore;
@property (nonatomic, readonly) size_t size;
@end

NS_ASSUME_NONNULL_END
