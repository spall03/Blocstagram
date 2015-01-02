//
//  BLCMediaTableViewCell.h
//  Blocstagram
//
//  Created by Stephen Palley on 12/22/14.
//  Copyright (c) 2014 Steve Palley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLCMedia.h"
#import "BLCComment.h"
#import "BLCUser.h"

@class BLCMedia, BLCMediaTableViewCell, BLCComposeCommentView;

@protocol BLCMediaTableViewCellDelegate <NSObject>

- (void)    cell:(BLCMediaTableViewCell *)cell didTapImageView:(UIImageView *)imageView;
- (void)    cell:(BLCMediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView;
- (void)    cell:(BLCMediaTableViewCell *)cell didTwoFingerTapCellView:(UIImageView *)imageView;
- (void)    cellDidPressLikeButton:(BLCMediaTableViewCell *)cell;

- (void) cellWillStartComposingComment:(BLCMediaTableViewCell *)cell;
- (void) cell:(BLCMediaTableViewCell *)cell didComposeComment:(NSString *)comment;

@end

@interface BLCMediaTableViewCell : UITableViewCell

@property (nonatomic, strong) BLCMedia *mediaItem;
@property (nonatomic, weak) id <BLCMediaTableViewCellDelegate> delegate;
@property (nonatomic, strong, readonly) BLCComposeCommentView *commentView;

+ (CGFloat) heightForMediaItem:(BLCMedia *)mediaItem width:(CGFloat)width;

- (void) stopComposingComment;

@end
