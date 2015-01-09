//
//  BLCMediaTableViewCellTest.m
//  Blocstagram
//
//  Created by Stephen Palley on 1/8/15.
//  Copyright (c) 2015 Steve Palley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BLCMedia.h"
#import "BLCMediaTableViewCell.h"

@interface BLCMediaTableViewCellTest : XCTestCase

@end

@implementation BLCMediaTableViewCellTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testHeightForMediaItemWorksCorrectly
{
  
    BLCMedia *testMedia = [BLCMedia new];
    UIImage *testImage = [[UIImage alloc]initWithContentsOfFile:@"/Users/spall/Desktop/Bloc/iOS/Blocstagram/Blocstagram/1.jpg"]; //2112 × 2816 pixels
    testMedia.image = testImage;
    CGFloat testImageHeight = (float)testMedia.image.size.height;
    CGFloat testWidth = 2000.0;
    
    CGFloat sizeRatio = testWidth / testImageHeight;
    
    CGFloat newHeight = [BLCMediaTableViewCell heightForMediaItem:testMedia width:testWidth];
    
    XCTAssertEqualWithAccuracy(newHeight, testImageHeight * sizeRatio, 1);
    
    
    
    
}



@end
