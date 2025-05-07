//
//  _NSFileBackedFuture.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/7/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol _NSFileBackedFuture <NSObject>
@property (readonly, nullable) NSURL *fileURL;
@property (readonly) size_t fileSize;
@property (readonly, null_unspecified) NSUUID *UUID;
@end

NS_ASSUME_NONNULL_END
