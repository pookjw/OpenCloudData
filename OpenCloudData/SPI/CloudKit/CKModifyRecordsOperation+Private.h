//
//  CKModifyRecordsOperation+Private.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 6/1/25.
//

#import <CloudKit/CloudKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CKModifyRecordsOperation (Private)
@property (nonatomic) BOOL markAsParticipantNeedsNewInvitationToken;
@end

NS_ASSUME_NONNULL_END
