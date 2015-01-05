//
//  BLCCameraToolbar.h
//  Blocstagram
//
//  Created by Stephen Palley on 1/4/15.
//  Copyright (c) 2015 Steve Palley. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLCCameraToolbar;

@protocol BLCCameraToolbarDelegate <NSObject>

- (void) leftButtonPressedOnToolbar:(BLCCameraToolbar *)toolbar;
- (void) rightButtonPressedOnToolbar:(BLCCameraToolbar *)toolbar;
- (void) cameraButtonPressedOnToolbar:(BLCCameraToolbar *)toolbar;

@end

@interface BLCCameraToolbar : UIView

- (instancetype) initWithImageNames:(NSArray *)imageNames;

@property (nonatomic, weak) NSObject <BLCCameraToolbarDelegate> *delegate;

@end
