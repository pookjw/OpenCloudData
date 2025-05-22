//
//  CKEncryptable.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/8/25.
//

#import <CloudKit/CloudKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CKEncryptable <NSObject>
@property (nonatomic, readonly) BOOL needsEncryption;
@property (nonatomic, readonly) BOOL needsDecryption;
@end

NS_ASSUME_NONNULL_END
