//
//  BLCDataSource.h
//  Blocstagram
//
//  Created by Stephen Palley on 12/22/14.
//  Copyright (c) 2014 Steve Palley. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLCMedia;

@interface BLCDataSource : NSObject

+(instancetype) sharedInstance;

@property (nonatomic, strong, readonly) NSMutableArray *mediaItems; //only the single instance of BLCDataSource can modify this

 - (void) deleteMediaItem:(BLCMedia *)item;

@end
