//
//  OCCloudKitSizeMetric.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/20/25.
//

#import <OpenCloudData/OCCloudKitBaseMetric.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCCloudKitSizeMetric : OCCloudKitBaseMetric
- (void)addByteSize:(size_t)byteSize __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
