//
//  OCCloudKitHistoryAnalyzerContext.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/20/25.
//

#import <OpenCloudData/PFHistoryAnalyzerContext.h>
#import <OpenCloudData/OCCloudKitHistoryAnalyzerOptions.h>
#import <OpenCloudData/NSSQLCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitHistoryAnalyzerContext : NSObject /* PFHistoryAnalyzerContext */
//{
//    NSManagedObjectContext *_managedObjectContext; // 0x40
//    NSSet<NSString *> *_configuredEntityNames; // 0x48
//    NSMutableSet<NSManagedObjectID *> *_resetChangedObjectIDs; // 0x50
//    NSMutableDictionary<NSNumber *, NSMutableSet<NSNumber *> *> *_entityIDToChangedPrimaryKeySet; // 0x58
//    NSSQLCore *_store; // 0x60
//}
- (instancetype)initWithOptions:(OCCloudKitHistoryAnalyzerOptions *)options managedObjectContext:(NSManagedObjectContext *)managedObjectContext store:(NSSQLCore *)store;
@end

NS_ASSUME_NONNULL_END
