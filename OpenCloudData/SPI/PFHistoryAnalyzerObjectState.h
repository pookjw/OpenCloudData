//
//  PFHistoryAnalyzerObjectState.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/10/25.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PFHistoryAnalyzerObjectState <NSObject>
@property (readonly, nonatomic, nullable) NSManagedObjectID *analyzedObjectID;
@property (readonly, nonatomic, null_unspecified) NSNumber *originalTransactionNumber;
@property (readonly, nonatomic) NSInteger originalChangeType;
@property (readonly, nonatomic, null_unspecified) NSNumber *finalTransactionNumber;
@property (readonly, nonatomic) NSInteger finalChangeType;
@property (readonly, nonatomic, null_unspecified) NSDictionary *tombstone;
@property (readonly, nonatomic, null_unspecified) NSString *finalChangeAuthor;
@property (readonly, nonatomic) NSInteger estimatedSizeInBytes;
- (void)updateWithChange:(NSPersistentHistoryChange *)change;
@end

NS_ASSUME_NONNULL_END
