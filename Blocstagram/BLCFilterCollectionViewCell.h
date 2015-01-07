//
//  BLCFilterCollectionViewCell.h
//  Blocstagram
//
//  Created by Stephen Palley on 1/7/15.
//  Copyright (c) 2015 Steve Palley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLCFilterCollectionViewCell : UICollectionViewCell

- (void) setupCellWithFlowLayout: (UICollectionViewFlowLayout*) flowLayout andThumbnail:(UIImage*) thumbnail andTitle:(NSString*) title;

@end
