//
//  BLCCameraViewController.m
//  Blocstagram
//
//  Created by Stephen Palley on 1/4/15.
//  Copyright (c) 2015 Steve Palley. All rights reserved.
//

#import "BLCCameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "BLCCameraToolbar.h"
#import "UIImage+BLCImageUtilities.h"
#import "BLCCropBox.h"
#import "BLCImageLibraryViewController.h"

 @interface BLCCameraViewController () <BLCCameraToolbarDelegate, UIAlertViewDelegate, BLCImageLibraryViewControllerDelegate>

@property (nonatomic, strong) UIView *imagePreview; //previews image from camera

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer; //displays video from camera
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput; //for still images

@property (nonatomic, strong) UIToolbar *topView;
@property (nonatomic, strong) UIToolbar *bottomView;

@property (nonatomic, strong) BLCCropBox *cropBox;
@property (nonatomic, strong) BLCCameraToolbar *cameraToolbar;

@end

@implementation BLCCameraViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Build View Hierarchy

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createViews];
    [self addViewsToViewHierarchy];
    [self setupImageCapture];
    [self createCancelButton];
}

- (void) createViews {
    self.imagePreview = [UIView new];
    self.topView = [UIToolbar new];
    self.bottomView = [UIToolbar new];
    self.cropBox = [BLCCropBox new];
    self.cameraToolbar = [[BLCCameraToolbar alloc] initWithImageNames:@[@"rotate", @"road"]]; //set toolbar images
    self.cameraToolbar.delegate = self; //plug into toolbar delegate
    UIColor *whiteBG = [UIColor colorWithWhite:1.0 alpha:.15];
    self.topView.barTintColor = whiteBG;
    self.bottomView.barTintColor = whiteBG;
    self.topView.alpha = 0.5;
    self.bottomView.alpha = 0.5; //translucent effect
}

- (void) addViewsToViewHierarchy {
    NSMutableArray *views = [@[self.imagePreview, self.cropBox, self.topView, self.bottomView] mutableCopy];
    [views addObject:self.cameraToolbar];
    
    
    //add views in proper z-layer order
    for (UIView *view in views) {
        [self.view addSubview:view];
    }
}

- (void) createCancelButton {
    UIImage *cancelImage = [UIImage imageNamed:@"x"];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:cancelImage style:UIBarButtonItemStyleDone target:self action:@selector(cancelPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButton; //stick cancel button in upper-left corner
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    self.topView.frame = CGRectMake(0, self.topLayoutGuide.length, width, 44);
    
    CGFloat yOriginOfBottomView = CGRectGetMaxY(self.topView.frame) + width;
    CGFloat heightOfBottomView = CGRectGetHeight(self.view.frame) - yOriginOfBottomView;
    self.bottomView.frame = CGRectMake(0, yOriginOfBottomView, width, heightOfBottomView);
    
    self.cropBox.frame = CGRectMake(0, CGRectGetMaxY(self.topView.frame), width, width);
    self.imagePreview.frame = self.view.bounds;
    self.captureVideoPreviewLayer.frame = self.imagePreview.bounds;
    
    CGFloat cameraToolbarHeight = 100;
    self.cameraToolbar.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - cameraToolbarHeight, width, cameraToolbarHeight);
}

#pragma mark - BLCCameraToolbarDelegate

- (void) cameraButtonPressedOnToolbar:(BLCCameraToolbar *)toolbar {
    AVCaptureConnection *videoConnection;
    
    // Find the right connection object
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        for (AVCaptureInputPort *port in connection.inputPorts) {
            if ([port.mediaType isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        if (imageSampleBuffer) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
            
            CGRect gridRect = self.cropBox.frame;
            CGRect cropRect = gridRect;
            cropRect.origin.x = (CGRectGetMinX(gridRect) + (image.size.width - CGRectGetWidth(gridRect)) / 2);

            image = [image imageByScalingToSize:self.captureVideoPreviewLayer.bounds.size andCroppingWithRect:cropRect];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate cameraViewController:self didCompleteWithImage:image];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.localizedDescription message:error.localizedRecoverySuggestion delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK button") otherButtonTitles:nil];
                [alert show];
            });
            
        }
    }];
}

//switch between front and back cameras
- (void) leftButtonPressedOnToolbar:(BLCCameraToolbar *)toolbar {
    AVCaptureDeviceInput *currentCameraInput = self.session.inputs.firstObject;
    
    //array of cameras able to take video
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    
    if (devices.count > 1) {
        NSUInteger currentIndex = [devices indexOfObject:currentCameraInput.device];
        NSUInteger newIndex = 0;
        
        if (currentIndex < devices.count - 1) {
            newIndex = currentIndex + 1;
        } //switch to first device if at end of device list
        
        AVCaptureDevice *newCamera = devices[newIndex];
        AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:nil]; //setup new device
        
        if (newVideoInput) { //animation for what exactly???
            UIView *fakeView = [self.imagePreview snapshotViewAfterScreenUpdates:YES];
            fakeView.frame = self.imagePreview.frame;
            [self.view insertSubview:fakeView aboveSubview:self.imagePreview];
            
            [self.session beginConfiguration];
            [self.session removeInput:currentCameraInput];
            [self.session addInput:newVideoInput];
            [self.session commitConfiguration];
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                fakeView.alpha = 0;
            } completion:^(BOOL finished) {
                [fakeView removeFromSuperview];
            }];
        }
    }
}

//choose image from photo library
- (void) rightButtonPressedOnToolbar:(BLCCameraToolbar *)toolbar {
    BLCImageLibraryViewController *imageLibraryVC = [[BLCImageLibraryViewController alloc] init];
    imageLibraryVC.delegate = self; //this cameraViewController is the imageLibrary's delegate
    [self.navigationController pushViewController:imageLibraryVC animated:YES];
}

#pragma mark - BLCImageLibraryViewControllerDelegate


//delegate method that passes image from image library, through camera view controller, to other VCs
- (void) imageLibraryViewController:(BLCImageLibraryViewController *)imageLibraryViewController didCompleteWithImage:(UIImage *)image {
    [self.delegate cameraViewController:self didCompleteWithImage:image];
}

#pragma mark - image capture stuff

- (void) setupImageCapture {
    
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetHigh; //set quality level for images
    
    self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill; //preserve video aspect ratio
    self.captureVideoPreviewLayer.masksToBounds = YES;
    [self.imagePreview.layer addSublayer:self.captureVideoPreviewLayer];
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{ //ask for user permission to use camera
            if (granted) {
                AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
                
                NSError *error = nil;
                AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error]; //set up input
                if (!input) { //error setting up input
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.localizedDescription message:error.localizedRecoverySuggestion delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK button") otherButtonTitles:nil];
                    [alert show];
                } else { //input sets up correctly
                    [self.session addInput:input];
                    
                    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init]; //for still images
                    self.stillImageOutput.outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG}; //set up video codec
                    
                    [self.session addOutput:self.stillImageOutput]; //hook up output to session obj
                    
                    [self.session startRunning]; //start session
                }
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Camera Permission Denied", @"camera permission denied title") //request denied
                                                                message:NSLocalizedString(@"This app doesn't have permission to use the camera; please update your privacy settings.", @"camera permission denied recovery suggestion")
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK button")
                                                      otherButtonTitles:nil];
                [alert show];
            }
        });
    }];

}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.delegate cameraViewController:self didCompleteWithImage:nil]; //delegate shuts down camera view
}

#pragma mark - Event Handling

- (void) cancelPressed:(UIBarButtonItem *)sender {
    [self.delegate cameraViewController:self didCompleteWithImage:nil]; //delegate shuts down camera view
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
