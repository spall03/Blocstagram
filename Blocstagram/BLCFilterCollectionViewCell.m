//
//  BLCFilterCollectionViewCell.m
//  Blocstagram
//
//  Created by Stephen Palley on 1/7/15.
//  Copyright (c) 2015 Steve Palley. All rights reserved.
//

#import "BLCFilterCollectionViewCell.h"

@implementation BLCFilterCollectionViewCell

static NSInteger imageViewTag = 1000;
static NSInteger labelTag = 1001;

- (void) setupCellWithFlowLayout: (UICollectionViewFlowLayout*) flowLayout andThumbnail:(UIImage*) thumb andTitle:(NSString*) title
{
    UIImageView *thumbnail = (UIImageView *)[self.contentView viewWithTag:imageViewTag];
    UILabel *label = (UILabel *)[self.contentView viewWithTag:labelTag];
    
    CGFloat thumbnailEdgeSize = flowLayout.itemSize.width;
    
    //makes empty thumbnail
    if (!thumbnail) {
        thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, thumbnailEdgeSize, thumbnailEdgeSize)];
        thumbnail.contentMode = UIViewContentModeScaleAspectFill;
        thumbnail.tag = imageViewTag;
        thumbnail.clipsToBounds = YES;
        
        [self.contentView addSubview:thumbnail];
    }
    
    //makes an empty label
    if (!label) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, thumbnailEdgeSize, thumbnailEdgeSize, 20)];
        label.tag = labelTag;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
        [self.contentView addSubview:label];
    }
    
    thumbnail.image = thumb;
    label.text = title;
    
}

@end
