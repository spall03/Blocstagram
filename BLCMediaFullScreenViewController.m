//
//  BLCMediaFullScreenViewController.m
//  Blocstagram
//
//  Created by Stephen Palley on 12/30/14.
//  Copyright (c) 2014 Steve Palley. All rights reserved.
//

#import "BLCMediaFullScreenViewController.h"
#import "BLCMedia.h"
#import "BLCMediaTableViewCell.h"

@interface BLCMediaFullScreenViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) BLCMedia *media;

@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;

@property (nonatomic, strong) UIButton *shareButton;

@end

@implementation BLCMediaFullScreenViewController

- (instancetype) initWithMedia:(BLCMedia *)media {
    self = [super init];
    
    if (self) {
        self.media = media;
    }
    
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView = [UIScrollView new];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.scrollView]; //main view, then scrollView
    
    self.imageView = [UIImageView new];
    self.imageView.image = self.media.image; //set imageView to picture
    
    [self.scrollView addSubview:self.imageView]; //main view, scrollView, imageView
    self.scrollView.contentSize = self.media.image.size; //resize scrollView
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
    
    self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapFired:)];
    self.doubleTap.numberOfTapsRequired = 2;
    
    [self.tap requireGestureRecognizerToFail:self.doubleTap]; //insure that this is actually a single-tap
    
    [self.scrollView addGestureRecognizer:self.tap];
    [self.scrollView addGestureRecognizer:self.doubleTap];
    
    //add share button
    UIButton* newShareButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [newShareButton setTitle:NSLocalizedString(@"Share", @"share button") forState:UIControlStateNormal];
    [newShareButton addTarget:self action:@selector(didTapShareButton) forControlEvents:UIControlEventTouchUpInside];
    newShareButton.backgroundColor = [UIColor whiteColor];
    [newShareButton sizeToFit];
    [newShareButton setFrame:CGRectMake(self.imageView.image.size.width - newShareButton.frame.size.width - 10, newShareButton.frame.size.height, newShareButton.frame.size.width, newShareButton.frame.size.height)];
    self.shareButton = newShareButton;
    [self.imageView addSubview:self.shareButton];
    
}

- (void) didTapShareButton {
    
    NSArray *itemsToShare = [self.media itemsToShare];
    
    if (itemsToShare.count > 0) {
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.scrollView.frame = self.view.bounds; //expand scrollView's frame to main view's bounds
    
    CGSize scrollViewFrameSize = self.scrollView.frame.size;
    CGSize scrollViewContentSize = self.scrollView.contentSize;
    
    CGFloat scaleWidth = scrollViewFrameSize.width / scrollViewContentSize.width;
    CGFloat scaleHeight = scrollViewFrameSize.height / scrollViewContentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    //biggest and smallest image can get when zoomed
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 1;
    

}

//center the scrollView the first time it is called
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self centerScrollView];
}

//make sure image is letterboxed properly in main view
- (void)centerScrollView {
    [self.imageView sizeToFit];
    
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - CGRectGetWidth(contentsFrame)) / 2; //recenter horizontally
    } else {
        contentsFrame.origin.x = 0;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - CGRectGetHeight(contentsFrame)) / 2; //recenter vertically
    } else {
        contentsFrame.origin.y = 0;
    }
    
    self.imageView.frame = contentsFrame;
}

#pragma mark - UIScrollViewDelegate

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Gesture Recognizers

- (void) tapFired:(UITapGestureRecognizer *)sender {
    [self dismissViewControllerAnimated:YES completion:nil]; //ditch the view that got tapped
}

- (void) doubleTapFired:(UITapGestureRecognizer *)sender {
    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) //if zoomed all the way out
    {
        CGPoint locationPoint = [sender locationInView:self.imageView]; //get tap location
        
        CGSize scrollViewSize = self.scrollView.bounds.size; //current size
        
        CGFloat width = scrollViewSize.width / self.scrollView.maximumZoomScale;
        CGFloat height = scrollViewSize.height / self.scrollView.maximumZoomScale;
        CGFloat x = locationPoint.x - (width / 2);
        CGFloat y = locationPoint.y - (height / 2);
        
        [self.scrollView zoomToRect:CGRectMake(x, y, width, height) animated:YES]; //zoom in on tap location
        
        
    } else { //if zoomed in at all
        
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES]; //zoom all the way out
    }
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
