//
//  BLCCameraViewController.h
//  Blocstagram
//
//  Created by Stephen Palley on 1/4/15.
//  Copyright (c) 2015 Steve Palley. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLCCameraViewController;

@protocol BLCCameraViewControllerDelegate <NSObject>

- (void) cameraViewController:(BLCCameraViewController *)cameraViewController didCompleteWithImage:(UIImage *)image;

@end

@interface BLCCameraViewController : UIViewController

@property (nonatomic, weak) NSObject <BLCCameraViewControllerDelegate> *delegate;

@end
