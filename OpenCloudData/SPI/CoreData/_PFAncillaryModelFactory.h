//
//  _PFAncillaryModelFactory.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/6/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol _PFAncillaryModelFactory <NSObject>
+ (NSUInteger)ancillaryEntityCount;
+ (NSUInteger)ancillaryEntityOffset;
+ (NSString *)ancillaryModelNamespace;
@end

NS_ASSUME_NONNULL_END
