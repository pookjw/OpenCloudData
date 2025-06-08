//
//  OCCKExportMetadata.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 6/8/25.
//

#import <CoreData/CoreData.h>
#import "OpenCloudData/Private/Model/OCCKExportOperation.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCCKExportMetadata : NSManagedObject
+ (NSString *)entityPath;
@property (retain, nonatomic, nullable) NSDate* exportedAt; 
@property (retain, nonatomic, nullable) NSString *identifier;
@property (retain, nonatomic, nullable) NSPersistentHistoryToken *historyToken;
@property (retain, nonatomic) NSSet<OCCKExportOperation *> *operations;
@end

NS_ASSUME_NONNULL_END
