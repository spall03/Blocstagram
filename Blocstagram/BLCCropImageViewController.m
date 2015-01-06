//
//  BLCCropImageViewController.m
//  Blocstagram
//
//  Created by Stephen Palley on 1/5/15.
//  Copyright (c) 2015 Steve Palley. All rights reserved.
//

#import "BLCCropImageViewController.h"
#import "BLCCropBox.h"
#import "BLCMedia.h"
#import "UIImage+BLCImageUtilities.h"

@interface BLCCropImageViewController ()

@property (nonatomic, strong) BLCCropBox *cropBox;
@property (nonatomic, assign) BOOL hasLoadedOnce;

@property (nonatomic, strong) UIToolbar *topView;
@property (nonatomic, strong) UIToolbar *bottomView;

@end

@implementation BLCCropImageViewController

- (instancetype) initWithImage:(UIImage *)sourceImage {
    self = [super init];
    
    if (self) {
        self.media = [[BLCMedia alloc] init];
        self.media.image = sourceImage;
        
        self.cropBox = [BLCCropBox new];
        self.topView = [UIToolbar new];
        self.bottomView = [UIToolbar new];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //fit into UI space
    self.view.clipsToBounds = YES;
    
    //add crop box and UIToolbars
    [self.view addSubview:self.cropBox];
    [self.view addSubview:self.topView];
    [self.view addSubview:self.bottomView];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Crop", @"Crop command") style:UIBarButtonItemStyleDone target:self action:@selector(cropPressed:)];
    
    //add crop button
    self.navigationItem.title = NSLocalizedString(@"Crop Image", nil]);
    self.navigationItem.rightBarButtonItem = rightButton;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    
    //color UIToolbars
    
    UIColor *whiteBG = [UIColor colorWithWhite:1.0 alpha:.15];
    self.topView.barTintColor = whiteBG;
    self.bottomView.barTintColor = whiteBG;
    self.topView.alpha = 0.5;
    self.bottomView.alpha = 0.5; //translucent effect
    
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
//    CGRect cropRect = CGRectZero;
//    
//    //make the view square
//    CGFloat edgeSize = MIN(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
//    cropRect.size = CGSizeMake(edgeSize, edgeSize);
//    
//    CGSize size = self.view.frame.size;
//    
//    //center crop box
//    self.cropBox.frame = cropRect;
//    self.cropBox.center = CGPointMake(size.width / 2, size.height / 2);
//    self.scrollView.frame = self.cropBox.frame;
//    self.scrollView.clipsToBounds = NO;
    
    //position UIToolbars
    CGFloat width = CGRectGetWidth(self.view.bounds);
    self.topView.frame = CGRectMake(0, self.topLayoutGuide.length, width, 44);
    
    CGFloat yOriginOfBottomView = CGRectGetMaxY(self.topView.frame) + width;
    CGFloat heightOfBottomView = CGRectGetHeight(self.view.frame) - yOriginOfBottomView;
    self.bottomView.frame = CGRectMake(0, yOriginOfBottomView, width, heightOfBottomView);
    
    //position cropbox relative to UIToolbars
    self.cropBox.frame = CGRectMake(0, CGRectGetMaxY(self.topView.frame), width, width);
    self.scrollView.frame = self.cropBox.frame;
    self.scrollView.clipsToBounds = NO;

    
    
    [self recalculateZoomScale];
    
    //zoom out
    if (self.hasLoadedOnce == NO) {
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
        self.hasLoadedOnce = YES;
    }
}

- (void) cropPressed:(UIBarButtonItem *)sender {
    CGRect visibleRect;
    float scale = 1.0f / self.scrollView.zoomScale / self.media.image.scale;
    visibleRect.origin.x = self.scrollView.contentOffset.x * scale;
    visibleRect.origin.y = self.scrollView.contentOffset.y * scale;
    visibleRect.size.width = self.scrollView.bounds.size.width * scale;
    visibleRect.size.height = self.scrollView.bounds.size.height * scale;
    
    UIImage *scrollViewCrop = [self.media.image imageWithFixedOrientation];
    scrollViewCrop = [scrollViewCrop imageCroppedToRect:visibleRect];
    
    [self.delegate cropControllerFinishedWithImage:scrollViewCrop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
