//
//  BLCImageLibraryViewController.h
//  Blocstagram
//
//  Created by Stephen Palley on 1/5/15.
//  Copyright (c) 2015 Steve Palley. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLCImageLibraryViewController;

@protocol BLCImageLibraryViewControllerDelegate <NSObject>

- (void) imageLibraryViewController:(BLCImageLibraryViewController *)imageLibraryViewController didCompleteWithImage:(UIImage *)image;

@end

@interface BLCImageLibraryViewController : UICollectionViewController

@property (nonatomic, weak) NSObject <BLCImageLibraryViewControllerDelegate> *delegate;

@end