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

@class BLCMedia;

@interface BLCMediaTableViewCell : UITableViewCell

@property (nonatomic, strong) BLCMedia *mediaItem;
//@property (nonatomic, strong) UIImageView *mediaImageView;
//@property (nonatomic, strong) UILabel *usernameAndCaptionLabel;
//@property (nonatomic, strong) UILabel *commentLabel;

+ (CGFloat) heightForMediaItem:(BLCMedia *)mediaItem width:(CGFloat)width;

@end
