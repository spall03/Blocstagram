//
//  BLCMediaFullScreenAnimator.h
//  Blocstagram
//
//  Created by Stephen Palley on 12/30/14.
//  Copyright (c) 2014 Steve Palley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface BLCMediaFullScreenAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL presenting; //is animation presenting or dismissing?
@property (nonatomic, weak) UIImageView *cellImageView;

@end
