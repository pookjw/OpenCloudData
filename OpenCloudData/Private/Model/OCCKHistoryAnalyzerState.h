//
//  OCCKHistoryAnalyzerState.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/10/25.
//

#import <CoreData/CoreData.h>
#import <OpenCloudData/PFHistoryAnalyzerObjectState.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCCKHistoryAnalyzerState : NSManagedObject <PFHistoryAnalyzerObjectState>
+ (NSString *)entityPath;
+ (BOOL)purgeAnalyzedHistoryFromStore:(__kindof NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
+ (NSNumber * _Nullable)countAnalyzerStatesInStore:(__kindof NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));

@property (retain, nonatomic) NSNumber *entityId;
@property (retain, nonatomic) NSNumber *entityPK;
@property (retain, nonatomic) NSNumber *originalChangeTypeNum;
@property (retain, nonatomic) NSNumber *finalChangeTypeNum;
@property (readonly, nonatomic) NSNumber *originalTransactionNumber;
@property (readonly, nonatomic) NSNumber *finalTransactionNumber;
@property (readonly, nonatomic, nullable) NSDictionary *tombstone;
@property (readonly, nonatomic, nullable) NSString *finalChangeAuthor;

- (void)mergeWithState:(id<PFHistoryAnalyzerObjectState>)state;
@end

NS_ASSUME_NONNULL_END
