//
//  BLCMediaFullScreenViewController.h
//  Blocstagram
//
//  Created by Stephen Palley on 12/30/14.
//  Copyright (c) 2014 Steve Palley. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLCMedia;

@interface BLCMediaFullScreenViewController : UIViewController

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

- (instancetype) initWithMedia:(BLCMedia *)media;

- (void) centerScrollView;

@end

