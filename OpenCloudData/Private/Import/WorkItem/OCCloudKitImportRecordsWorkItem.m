//
//  OCCloudKitImportRecordsWorkItem.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/15/25.
//

#import <OpenCloudData/OCCloudKitImportRecordsWorkItem.h>

@implementation OCCloudKitImportRecordsWorkItem

- (instancetype)initWithOptions:(OCCloudKitImporterOptions *)options request:(OCCloudKitMirroringImportRequest *)request {
    /*
     options = x20
     */
    if (self = [super initWithOptions:options request:request]) {
        _importOperationIdentifier = [[NSUUID alloc] init];
        _assetPathToSafeSaveURL = [[NSMutableDictionary alloc] init];
        _updatedRecords = [[NSMutableArray alloc] init];
        _recordTypeToDeletedRecordID = [[NSMutableDictionary alloc] init];
        _allRecordIDs = [[NSMutableArray alloc] init];
        _totalOperationBytes = 0;
        _currentOperationBytes = 0;
        _countUpdatedRecords = 0;
        _countDeletedRecords = 0;
        _encounteredErrors = [[NSMutableArray alloc] init];
        _failedRelationships = [[NSMutableArray alloc] init];
        _fetchedRecordBytesMetric = [[OCCloudKitFetchedRecordBytesMetric alloc] initWithContainerIdentifier:options.options.containerIdentifier];
        _fetchedAssetBytesMetric = [[OCCloudKitFetchedAssetBytesMetric alloc] initWithContainerIdentifier:options.options.containerIdentifier];
        _incrementalResults = [[NSMutableArray alloc] init];
        _unknownItemRecordIDs = [[NSMutableArray alloc] init];
        _updatedShares = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

@end
