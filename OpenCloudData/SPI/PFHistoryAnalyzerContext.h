//
//  PFHistoryAnalyzerContext.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/20/25.
//

#import <OpenCloudData/PFHistoryAnalyzerOptions.h>
#import <OpenCloudData/PFHistoryAnalyzerDefaultObjectState.h>
#import <OpenCloudData/PFHistoryAnalyzerObjectState.h>

NS_ASSUME_NONNULL_BEGIN

@interface PFHistoryAnalyzerContext : NSObject {
@private BOOL _isFinished; // 0x8
@private PFHistoryAnalyzerOptions *_options; // 0x10
@private NSMutableDictionary<NSManagedObjectID *, id<PFHistoryAnalyzerObjectState>> *_objectIDToState; // 0x18
@private NSArray<id<PFHistoryAnalyzerObjectState>> *_sortedStates; // 0x20
@private NSMutableSet<NSNumber *> *_processedTransactionIDs; // 0x28
@private NSPersistentHistoryToken *_finalHistoryToken; // 0x30
@private long _accumulatedChangeBytes; // 0x38
}
- (instancetype)initWithOptions:(PFHistoryAnalyzerOptions *)options;
- (BOOL)reset:(NSError * _Nullable * _Nullable)error;
- (PFHistoryAnalyzerDefaultObjectState * _Nullable)analyzerStateForChangedObjectID:(NSManagedObjectID *)objectID error:(NSError * _Nullable * _Nullable)error;
- (NSArray<id<PFHistoryAnalyzerObjectState>> * _Nullable)fetchSortedStates:(NSError * _Nullable * _Nullable)error NS_RETURNS_RETAINED;
- (BOOL)finishProcessing:(NSError * _Nullable * _Nullable)error;
- (id<PFHistoryAnalyzerObjectState> _Nullable)newAnalyzerStateForChange:(NSPersistentHistoryChange *)change error:(NSError * _Nullable * _Nullable)error;
- (BOOL)processChange:(NSPersistentHistoryChange *)change error:(NSError * _Nullable * _Nullable)error;
- (BOOL)processTransaction:(NSPersistentHistoryTransaction *)transaction error:(NSError * _Nullable * _Nullable)error;
- (BOOL)resetStateForObjectID:(NSManagedObjectID *)objectID error:(NSError * _Nullable * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
