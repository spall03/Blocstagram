//
//  BLCComposeCommentViewTest.m
//  Blocstagram
//
//  Created by Stephen Palley on 1/8/15.
//  Copyright (c) 2015 Steve Palley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BLCComposeCommentView.h"

@interface BLCComposeCommentViewTest : XCTestCase

@end

@implementation BLCComposeCommentViewTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSetTextWorkCorrectlyWithText {
    
    BLCComposeCommentView* testCommentView = [BLCComposeCommentView new];
    NSString* testText = @"This is some text.";
    
    [testCommentView setText:testText];
    
    XCTAssertTrue(testCommentView.isWritingComment);
}

- (void)testSetTextWorkCorrectlyWithoutText {
    
    BLCComposeCommentView* testCommentView = [BLCComposeCommentView new];
    
    XCTAssertFalse(testCommentView.isWritingComment);
    
    
}

@end
