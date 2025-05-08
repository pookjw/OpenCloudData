//
//  _NSDataFileBackedFuture.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/7/25.
//

#import <OpenCloudData/_NSFileBackedFuture.h>

NS_ASSUME_NONNULL_BEGIN

@interface _NSDataFileBackedFuture : NSData <_NSFileBackedFuture>
- (instancetype)initWithStoreMetadata:(NSData *)storeMetadata directory:(NSURL *)directory originalFileURL:(NSURL *)originalFileURL;
- (instancetype)initWithStoreMetadata:(NSData *)storeMetadata directory:(NSURL *)directory;
@end

NS_ASSUME_NONNULL_END
