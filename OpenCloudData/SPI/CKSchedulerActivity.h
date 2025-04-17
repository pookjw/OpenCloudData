//
//  CKSchedulerActivity.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import <CloudKit/CloudKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CKSchedulerActivity : NSObject <NSCopying/*, CKPropertiesDescription*/>
@property BOOL shouldDefer;
@end

NS_ASSUME_NONNULL_END
