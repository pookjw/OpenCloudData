//
//  OCCloudKitExportContext.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/5/25.
//

#import <CoreData/CoreData.h>
#import <OpenCloudData/OCCloudKitExporterOptions.h>
#import <OpenCloudData/NSSQLCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitExportContext : NSObject {
    OCCloudKitExporterOptions *_options;
    NSUInteger _totalBytes;
    NSUInteger _totalRecords;
    NSUInteger _totalRecordIDs;
    NSMutableArray *_writtenAssetURLs;
}
- (instancetype)initWithOptions:(OCCloudKitExporterOptions *)options;
- (BOOL)processAnalyzedHistoryInStore:(NSSQLCore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error;
- (BOOL)checkForObjectsNeedingExportInStore:(__kindof NSPersistentStore *)store andReturnCount:(NSUInteger *)count withManagedObjectContext:(NSManagedObjectContext * _Nullable)managedObjectContext error:(NSError * _Nullable * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
