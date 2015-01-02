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
#import <AFNetworking/AFNetworking.h>



@interface BLCDataSource (){
    
    NSMutableArray *_mediaItems;
    
}

@property (nonatomic, strong) NSMutableArray *mediaItems; //this obj (.self) can modify array

@property (nonatomic, strong) NSString *accessToken;

@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isLoadingOlderItems;
@property (nonatomic, assign) BOOL thereAreNoMoreOlderMessages; //no more infinite scroll

@property (nonatomic, strong) AFHTTPRequestOperationManager *instagramOperationManager;


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
        
        NSURL *baseURL = [NSURL URLWithString:@"https://api.instagram.com/v1/"];
        self.instagramOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL]; //initialize Ops Manager
        
        AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializer];
        
        AFImageResponseSerializer *imageSerializer = [AFImageResponseSerializer serializer];
        imageSerializer.imageScale = 1.0; //AFImageResponseSerializer can make its own sizes
        
        AFCompoundResponseSerializer *serializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[jsonSerializer, imageSerializer]]; //combines the JSON and Image serializers into a single object
        self.instagramOperationManager.responseSerializer = serializer;
        
        
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
        
        NSMutableDictionary *mutableParameters = [@{@"access_token": self.accessToken} mutableCopy]; //parameterize access token
        
        [mutableParameters addEntriesFromDictionary:parameters]; //add additional parameters
        
        [self.instagramOperationManager GET:@"users/self/feed" //let OperationManager do its thing
                                 parameters:mutableParameters
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                            [self parseDataFromFeedDictionary:responseObject fromRequestWithParameters:parameters];
                                            
                                            if (completionHandler) {
                                                completionHandler(nil);
                                            }
                                        }
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        if (completionHandler) {
                                            completionHandler(error);
                                        }
                                    }];
    }
}

- (void) downloadImageForMediaItem:(BLCMedia *)mediaItem {
    if (mediaItem.mediaURL && !mediaItem.image) { //if not already downloaded and URL present
        
        mediaItem.downloadState = BLCMediaDownloadStateDownloadInProgress;
        
        [self.instagramOperationManager GET:mediaItem.mediaURL.absoluteString
                                 parameters:nil
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        if ([responseObject isKindOfClass:[UIImage class]]) {
                                            mediaItem.image = responseObject; //put image into mediaItem
                                            mediaItem.downloadState = BLCMediaDownloadStateHasImage; //switch flag to has image
                                            NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"]; //open mediaItems array via KVO
                                            NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem]; //find index
                                            [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem]; //sub in the new image
                                        }
                                        else
                                        {
                                            mediaItem.downloadState = BLCMediaDownloadStateNonRecoverableError; //download didn't work
                                        }
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        NSLog(@"Error downloading image: %@", error);
                                        
                                        mediaItem.downloadState = BLCMediaDownloadStateNonRecoverableError;
                                        
                                        if ([error.domain isEqualToString:NSURLErrorDomain]) {
                                            // A networking problem
                                            if (error.code == NSURLErrorTimedOut ||
                                                error.code == NSURLErrorCancelled ||
                                                error.code == NSURLErrorCannotConnectToHost ||
                                                error.code == NSURLErrorNetworkConnectionLost ||
                                                error.code == NSURLErrorNotConnectedToInternet ||
                                                error.code == kCFURLErrorInternationalRoamingOff ||
                                                error.code == kCFURLErrorCallIsActive ||
                                                error.code == kCFURLErrorDataNotAllowed ||
                                                error.code == kCFURLErrorRequestBodyStreamExhausted) {
                                                
                                                // It might work if we try again
                                                mediaItem.downloadState = BLCMediaDownloadStateNeedsImage;
                                            }
                                        }
                                    }];
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
            // disable infinite scroll, since there are no more older messages.
            self.thereAreNoMoreOlderMessages = YES;
        }
        
        [mutableArrayWithKVO addObjectsFromArray:tmpMediaItems];
    
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

#pragma mark - Liking Media Items

- (void) toggleLikeOnMediaItem:(BLCMedia *)mediaItem {
    NSString *urlString = [NSString stringWithFormat:@"media/%@/likes", mediaItem.idNumber];
    NSDictionary *parameters = @{@"access_token": self.accessToken};
    
    if (mediaItem.likeState == BLCLikeStateNotLiked) { //toggle from unliked to liked
        
        mediaItem.likeState = BLCLikeStateLiking;
        
        [self.instagramOperationManager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) { //inform instagram by POSTing urlString
            mediaItem.likeState = BLCLikeStateLiked;
            mediaItem.likeNumber = mediaItem.likeNumber+1;
            [self reloadMediaItem:mediaItem]; //reload mediaItem
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            mediaItem.likeState = BLCLikeStateNotLiked;
            [self reloadMediaItem:mediaItem];
        }];
        
    } else if (mediaItem.likeState == BLCLikeStateLiked) { //toggle from liked to unliked
        
        mediaItem.likeState = BLCLikeStateUnliking;
        
        [self.instagramOperationManager DELETE:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) { //inform instagram by DELETEing urlString
            mediaItem.likeState = BLCLikeStateNotLiked;
            mediaItem.likeNumber = mediaItem.likeNumber-1;
            [self reloadMediaItem:mediaItem];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            mediaItem.likeState = BLCLikeStateLiked;
            [self reloadMediaItem:mediaItem];
        }];
        
    }
    
    [self reloadMediaItem:mediaItem];
}




- (void) reloadMediaItem:(BLCMedia *)mediaItem {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
    [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
}

#pragma mark - Comments

- (void) commentOnMediaItem:(BLCMedia *)mediaItem withCommentText:(NSString *)commentText {
    if (!commentText || commentText.length == 0) { //no comment, so cancel
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"media/%@/comments", mediaItem.idNumber];
    NSDictionary *parameters = @{@"access_token": self.accessToken, @"text": commentText};
    
    [self.instagramOperationManager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) { //attempting to post new comment to Instagram
        mediaItem.temporaryComment = nil; //clear temporaryComment cache
        
        NSString *refreshMediaUrlString = [NSString stringWithFormat:@"media/%@", mediaItem.idNumber];
        NSDictionary *parameters = @{@"access_token": self.accessToken};
        [self.instagramOperationManager GET:refreshMediaUrlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) { //if it works, refresh the mediaItem from Instagram
            BLCMedia *newMediaItem = [[BLCMedia alloc] initWithDictionary:responseObject];
            NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
            NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
            [mutableArrayWithKVO replaceObjectAtIndex:index withObject:newMediaItem];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self reloadMediaItem:mediaItem];
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSLog(@"Response: %@", operation.responseString);
        [self reloadMediaItem:mediaItem];
    }];
}

@end
