//
//  OCCloudKitExporter.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/4/25.
//

#import <CloudKit/CloudKit.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@class OCCloudKitExporter;
@protocol OCCloudKitExporterDelegate <NSObject>
- (void)exporter:(OCCloudKitExporter *)exporter willScheduleOperations:(NSArray<__kindof CKOperation *> *)operations;
@end

@interface OCCloudKitExporter : NSObject

@end

NS_ASSUME_NONNULL_END
