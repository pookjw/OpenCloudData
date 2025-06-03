//
//  CKAccountInfo.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 6/1/25.
//

#import <CloudKit/CloudKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CKAccountInfo : NSObject <NSSecureCoding>
@property (nonatomic) NSInteger deviceToDeviceEncryptionAvailability;
@property (nonatomic) NSInteger accountStatus;
@property (nonatomic) BOOL hasValidCredentials;
@end

NS_ASSUME_NONNULL_END
