//
//  OCCloudKitImportRecordsWorkItem.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/15/25.
//

#import <OpenCloudData/OCCloudKitImporterWorkItem.h>
#import <OpenCloudData/OCCloudKitFetchedRecordBytesMetric.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitImportRecordsWorkItem : OCCloudKitImporterWorkItem {
    @package OCCloudKitFetchedRecordBytesMetric *_fetchedRecordBytesMetric; // 0x40
}

@end

NS_ASSUME_NONNULL_END
