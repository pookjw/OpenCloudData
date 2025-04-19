//
//  OCCloudKitMetricsClient.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/20/25.
//

#import <Foundation/Foundation.h>
#import <OpenCloudData/OCCloudKitBaseMetric.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitMetricsClient : NSObject
- (void)logMetric:(OCCloudKitBaseMetric *)metric __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
