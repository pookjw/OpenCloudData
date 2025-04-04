//
//  OCCloudKitMirroringDelegate.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import <CloudKit/CloudKit.h>
#import <OpenCloudData/NSPersistentStoreMirroringDelegate.h>
#import <OpenCloudData/OCCloudKitMirroringDelegateOptions.h>
#import <OpenCloudData/OCCloudKitExporter.h>
#import <OpenCloudData/PFApplicationStateMonitorDelegate.h>
#import <OpenCloudData/OCCloudKitMirroringDelegateProgressProvider.h>
#import <OpenCloudData/OCPersistentCloudKitContainerActivityVoucher.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCCloudKitMirroringDelegate : NSObject <OCCloudKitExporterDelegate, PFApplicationStateMonitorDelegate, OCCloudKitMirroringDelegateProgressProvider, NSPersistentStoreMirroringDelegate> {
    @package OCCloudKitMirroringDelegateOptions *_options;
    @package BOOL _successfullyInitialized;
    @package CKRecordID *_currentUserRecordID;
}
+ (NSValueTransformerName)cloudKitMetadataTransformerName;
- (void)addActivityVoucher:(OCPersistentCloudKitContainerActivityVoucher *)activityVoucher;
- (void)expireActivityVoucher:(OCPersistentCloudKitContainerActivityVoucher *)activityVoucher;
@end

NS_ASSUME_NONNULL_END
