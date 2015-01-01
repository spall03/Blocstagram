//
//  BLCDataSource.h
//  Blocstagram
//
//  Created by Stephen Palley on 12/22/14.
//  Copyright (c) 2014 Steve Palley. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLCMedia;

typedef void (^BLCNewItemCompletionBlock)(NSError *error);

@interface BLCDataSource : NSObject

+(instancetype) sharedInstance;
+(NSString *) instagramClientID;


@property (nonatomic, strong, readonly) NSMutableArray *mediaItems; //only the single instance of BLCDataSource can modify this
@property (nonatomic, strong, readonly) NSString *accessToken;

- (void) deleteMediaItem:(BLCMedia *)item;
- (void) downloadImageForMediaItem:(BLCMedia *)item;


- (void) requestNewItemsWithCompletionHandler:(BLCNewItemCompletionBlock)completionHandler;
- (void) requestOldItemsWithCompletionHandler:(BLCNewItemCompletionBlock)completionHandler;

@end
