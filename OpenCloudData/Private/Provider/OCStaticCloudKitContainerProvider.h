//
//  OCStaticCloudKitContainerProvider.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/27/25.
//

#import <OpenCloudData/OCCloudKitContainerProvider.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCStaticCloudKitContainerProvider : OCCloudKitContainerProvider
// original : nonatomic, readonly
@property (retain, nonatomic, readonly) CKContainer *container;
- (instancetype)initWithContainer:(CKContainer *)container;
@end

NS_ASSUME_NONNULL_END
