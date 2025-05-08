//
//  NSCKRecordMetadata.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/8/25.
//

#import <CoreData/CoreData.h>
#import <CloudKit/CloudKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSCKRecordMetadata : NSManagedObject
+ (NSData * _Nullable)encodeRecord:(CKRecord *)record error:(NSError * _Nullable * _Nullable)error NS_RETURNS_RETAINED;
@end

NS_ASSUME_NONNULL_END
