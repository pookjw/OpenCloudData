//
//  CKEncryptedData.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/8/25.
//

#import "OpenCloudData/SPI/CloudKit/CKEncryptable.h"

NS_ASSUME_NONNULL_BEGIN

@interface CKEncryptedData : NSObject <CKEncryptable, CKRecordValue, NSCopying, NSSecureCoding>
@property (copy) NSData *data;
@end

NS_ASSUME_NONNULL_END
