//
//  _NSDataFileBackedFuture.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/7/25.
//

#import <OpenCloudData/_NSFileBackedFuture.h>

NS_ASSUME_NONNULL_BEGIN

@interface _NSDataFileBackedFuture : NSData <_NSFileBackedFuture> {
@private NSURL * _Nullable _fileURL; // 0x8
@private NSURL *_originalFileURL; // 0x10
@private size_t _fileSize; // 0x18
@private NSUUID *_uuid; // 0x20
@private NSData *_realData; // 0x28
@private NSData *_bytes; // 0x30
}
- (instancetype)initWithStoreMetadata:(NSData *)storeMetadata directory:(NSURL *)directory originalFileURL:(NSURL *)originalFileURL;
- (instancetype)initWithStoreMetadata:(NSData *)storeMetadata directory:(NSURL *)directory;
@end

NS_ASSUME_NONNULL_END
