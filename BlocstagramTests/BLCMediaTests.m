//
//  BLCMediaTests.m
//  Blocstagram
//
//  Created by Stephen Palley on 1/7/15.
//  Copyright (c) 2015 Steve Palley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BLCMedia.h"

@interface BLCMediaTests : XCTestCase

@end

@implementation BLCMediaTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//only going to test properties that are simple data objects
- (void)testThatInitializationWorks
{
    
    
    NSData* data = [NSData dataWithContentsOfFile:@"/Users/spall/Desktop/Bloc/iOS/Blocstagram/BlocstagramTests/instagramJSON.rtf"];
    
    NSDictionary* sourceDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    BLCMedia *testMedia = [[BLCMedia alloc] initWithDictionary:sourceDictionary];
    
    XCTAssertEqualObjects(testMedia.idNumber, sourceDictionary[@"id"], @"The ID number should be equal");
    XCTAssertEqual(testMedia.likeNumber, sourceDictionary[@"likes"][@"count"]);
//    XCTAssertEqual(testMedia.caption, sourceDictionary[@"caption"][@"text"]);
}

@end
