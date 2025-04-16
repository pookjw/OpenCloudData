//
//  CKRecordValueStore.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/16/25.
//

#import <CloudKit/CloudKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CKRecordValueStore : NSObject <CKRecordKeyValueSetting, NSCopying, NSSecureCoding>

@end

NS_ASSUME_NONNULL_END
