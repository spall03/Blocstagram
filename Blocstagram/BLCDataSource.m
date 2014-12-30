//
//  BLCDataSource.m
//  Blocstagram
//
//  Created by Stephen Palley on 12/22/14.
//  Copyright (c) 2014 Steve Palley. All rights reserved.
//

#import "BLCDataSource.h"
#import "BLCUser.h"
#import "BLCMedia.h"
#import "BLCComment.h"
#import "BLCLoginViewController.h"
#import <UICKeyChainStore.h>



@interface BLCDataSource (){
    
    NSMutableArray *_mediaItems;
    
}

@property (nonatomic, strong) NSMutableArray *mediaItems; //this obj (.self) can modify array

@property (nonatomic, strong) NSString *accessToken;

@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isLoadingOlderItems;
@property (nonatomic, assign) BOOL thereAreNoMoreOlderMessages; //no more infinite scroll


@end

@implementation BLCDataSource

+ (instancetype) sharedInstance
{
    
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{ //this only happens once
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
    
}

+ (NSString *) instagramClientID {
    return @"cd3c2dc846a84f05a1f96cef123c5e25";
}

//infinite scroll
- (void) requestOldItemsWithCompletionHandler:(BLCNewItemCompletionBlock)completionHandler {
     if (self.isLoadingOlderItems == NO && self.thereAreNoMoreOlderMessages == NO) { //check to see if there are older items to load
        self.isLoadingOlderItems = YES;
        
        
         NSString *maxID = [[self.mediaItems lastObject] idNumber]; //get the ID for the last image in the mediaItems array
         NSDictionary *parameters = @{@"max_id": maxID};
         
         [self populateDataWithParameters:parameters completionHandler:^(NSError *error) { //start populating at the last image
             self.isLoadingOlderItems = NO;
             
             if (completionHandler) { //???
                 completionHandler(error);
             }
         }];
    }
}

//pull to refresh
- (void) requestNewItemsWithCompletionHandler:(BLCNewItemCompletionBlock)completionHandler {
    self.thereAreNoMoreOlderMessages = NO; //why would this necessarily change?
    
    if (self.isRefreshing == NO) {
        self.isRefreshing = YES;
       
        //add images here
        
        NSString *minID = [[self.mediaItems firstObject] idNumber]; //get the ID for the first item in the mediaItems array
        NSDictionary *parameters = [NSDictionary new];
        
        if (minID != nil)
        {
            parameters = @{@"min_id": minID};
        }
        else //if mediaItems is empty, repopulate it as if the app were loading for the first time
        {
            parameters = nil;
        }
        
        
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error) { //repopulate from Instagram
            self.isRefreshing = NO;
            
            if (completionHandler) { //???
                completionHandler(error);
            }
        }];
    }
}

- (instancetype) init
{
    self = [super init];
    
    if (self) {
        self.accessToken = [UICKeyChainStore stringForKey:@"access token"]; //grab token from keychain
        
        if (!self.accessToken)
        {
            [self registerForAccessTokenNotification]; //try again???
        }
        else
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
                NSArray *storedMediaItems = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath]; //load up stored items from disk
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (storedMediaItems.count > 0) {
                        NSMutableArray *mutableMediaItems = [storedMediaItems mutableCopy];
                        
                        [self willChangeValueForKey:@"mediaItems"];
                        self.mediaItems = mutableMediaItems;
                        
                        [self requestNewItemsWithCompletionHandler:nil];//automatically download new stuff after loading old stuff
                        
                        [self didChangeValueForKey:@"mediaItems"]; //notify as usual
                    } else {
                        [self populateDataWithParameters:nil completionHandler:nil]; //if no stored items, go to Instagram and download some
                    }
                });
            });
        }
    }
    
    return self;
}

- (void) registerForAccessTokenNotification {
    [[NSNotificationCenter defaultCenter] addObserverForName:BLCLoginViewControllerDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.accessToken = note.object; //lets us know if Instagram is playing ball
        [UICKeyChainStore setString:self.accessToken forKey:@"access token"]; //save token in keychain
        
        
        [self populateDataWithParameters:nil completionHandler:nil];;
    }];
}


- (void) deleteMediaItem:(BLCMedia *)item {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"]; //KVOs us into the mediaItems array
    [mutableArrayWithKVO removeObject:item];
}

- (void) populateDataWithParameters:(NSDictionary *)parameters completionHandler:(BLCNewItemCompletionBlock)completionHandler {
    if (self.accessToken) {
        // only try to get the data if there's an access token
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            // do the network request in the background, so the UI doesn't lock up
            
            NSMutableString *urlString = [NSMutableString stringWithFormat:@"https://api.instagram.com/v1/users/self/feed?access_token=%@", self.accessToken]; //building Instagram login URL string
            
            for (NSString *parameterName in parameters) {
                // for example, if dictionary contains {count: 50}, append `&count=50` to the URL
                [urlString appendFormat:@"&%@=%@", parameterName, parameters[parameterName]]; //using Instagram's syntax for URL requests
            }
            
            NSURL *url = [NSURL URLWithString:urlString]; //build URL obj
            
            if (url) {
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                
                NSURLResponse *response;
                NSError *webError;
                NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&webError]; //passing by reference allows us to get multiple returns back from Instagram
                
                if (responseData) {
                    NSError *jsonError;
                    NSDictionary *feedDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
                    //make dictionary out of Instagram's JSON object
                    
                    
                    if (feedDictionary) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // done networking, go back on the main thread
                            [self parseDataFromFeedDictionary:feedDictionary fromRequestWithParameters:parameters]; //begin chopping apart the data dictionary
                            if (completionHandler) {
                                completionHandler(nil);
                            }
                        });
                    } else if (completionHandler) { //JSON parsing error if no feedDictionary
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionHandler(jsonError);
                        });
                    }
                } else if (completionHandler) { //web error if no responseData
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // done networking, go back on the main thread
                        completionHandler(webError);
                    });
                }
            }
        });
    }
}

- (void) downloadImageForMediaItem:(BLCMedia *)mediaItem {
    if (mediaItem.mediaURL && !mediaItem.image) { //if not already downloaded and URL present
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURLRequest *request = [NSURLRequest requestWithURL:mediaItem.mediaURL];
            
            NSURLResponse *response;
            NSError *error;
            NSData *imageData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            if (imageData) {
                UIImage *image = [UIImage imageWithData:imageData]; //make UIImage out of UIData object wrapper
                
                if (image) {
                    mediaItem.image = image;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"]; //KVO new image into mediaItems array
                        NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
                        [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
                    });
                }
            } else {
                NSLog(@"Error downloading image: %@", error);
            }
        });
    }
}

//this chops up Instagram's JSON feed into stuff we can use
- (void) parseDataFromFeedDictionary:(NSDictionary *) feedDictionary fromRequestWithParameters:(NSDictionary *)parameters {
    NSArray *mediaArray = feedDictionary[@"data"]; //grabs each post
    
    NSMutableArray *tmpMediaItems = [NSMutableArray array];
    
    for (NSDictionary *mediaDictionary in mediaArray) { //for each Instagram post we pulled down
        BLCMedia *mediaItem = [[BLCMedia alloc] initWithDictionary:mediaDictionary]; //make new Media object
        
        if (mediaItem) {
            [tmpMediaItems addObject:mediaItem]; //add to temporary array
            [self downloadImageForMediaItem:mediaItem]; //download picture
        }
    }
    
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"]; //KVO into mediaItems array
    
    if (parameters[@"min_id"]) {
        // This was a pull-to-refresh request
        
        NSRange rangeOfIndexes = NSMakeRange(0, tmpMediaItems.count); //indexes of all the new stuff
        NSIndexSet *indexSetOfNewObjects = [NSIndexSet indexSetWithIndexesInRange:rangeOfIndexes];
        
        [mutableArrayWithKVO insertObjects:tmpMediaItems atIndexes:indexSetOfNewObjects]; //put in the new stuff via KVO
    } else if (parameters[@"max_id"]) {
        // This was an infinite scroll request
        
        if (tmpMediaItems.count == 0) {
            // disable infinite scroll, since there are no more older messages. ???
            self.thereAreNoMoreOlderMessages = YES;
        }
        
        [mutableArrayWithKVO addObjectsFromArray:tmpMediaItems]; //???
    
    } else {
        [self willChangeValueForKey:@"mediaItems"]; //KVO notification
        self.mediaItems = tmpMediaItems;
        [self didChangeValueForKey:@"mediaItems"];
    }
    
    if (tmpMediaItems.count > 0) {
        // Write the changes to disk
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSUInteger numberOfItemsToSave = MIN(self.mediaItems.count, 50); //limited to 50 items
            NSArray *mediaItemsToSave = [self.mediaItems subarrayWithRange:NSMakeRange(0, numberOfItemsToSave)];
            
            NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))]; //make path
            NSData *mediaItemData = [NSKeyedArchiver archivedDataWithRootObject:mediaItemsToSave]; //encode into data obj
            
            NSError *dataError;
            BOOL wroteSuccessfully = [mediaItemData writeToFile:fullPath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError]; //attempt to write data
            
            if (!wroteSuccessfully) {
                NSLog(@"Couldn't write file: %@", dataError); //log error if necessary
            }
        });
        
    }
}

//build full path string to find a filename
- (NSString *) pathForFilename:(NSString *) filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:filename];
    return dataPath;
}

#pragma mark - Key/Value Observing

- (NSUInteger) countOfMediaItems {
    return self.mediaItems.count;
}

- (id) objectInMediaItemsAtIndex:(NSUInteger)index {
    return [self.mediaItems objectAtIndex:index];
}

- (NSArray *) mediaItemsAtIndexes:(NSIndexSet *)indexes {
    return [self.mediaItems objectsAtIndexes:indexes];
}

- (void) insertObject:(BLCMedia *)object inMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems insertObject:object atIndex:index];
}

- (void) removeObjectFromMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems removeObjectAtIndex:index];
}

- (void) replaceObjectInMediaItemsAtIndex:(NSUInteger)index withObject:(id)object {
    [_mediaItems replaceObjectAtIndex:index withObject:object];
}

@end
