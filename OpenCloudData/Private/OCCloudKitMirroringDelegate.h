//
//  OCCloudKitMirroringDelegate.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import <CloudKit/CloudKit.h>
#import <OpenCloudData/NSPersistentStoreMirroringDelegate.h>
#import <OpenCloudData/OCCloudKitMirroringDelegateOptions.h>
#import <OpenCloudData/OCPersistentCloudKitContainerActivityVoucher.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCCloudKitMirroringDelegate : NSObject <NSPersistentStoreMirroringDelegate> {
    @package OCCloudKitMirroringDelegateOptions *_options;
    @package BOOL _successfullyInitialized;
    @package CKRecordID *_currentUserRecordID;
}
- (void)addActivityVoucher:(OCPersistentCloudKitContainerActivityVoucher *)activityVoucher;
@end

NS_ASSUME_NONNULL_END
