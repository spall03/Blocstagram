//
//  BLCMedia.m
//  Blocstagram
//
//  Created by Stephen Palley on 12/22/14.
//  Copyright (c) 2014 Steve Palley. All rights reserved.
//

#import "BLCMedia.h"
#import "BLCUser.h"
#import "BLCComment.h"

@implementation BLCMedia

- (instancetype) initWithDictionary:(NSDictionary *)mediaDictionary {
    self = [super init];
    
    if (self) {
        self.idNumber = mediaDictionary[@"id"];
        self.user = [[BLCUser alloc] initWithDictionary:mediaDictionary[@"user"]];
        NSString *standardResolutionImageURLString = mediaDictionary[@"images"][@"standard_resolution"][@"url"];
        NSURL *standardResolutionImageURL = [NSURL URLWithString:standardResolutionImageURLString];
        
        if (standardResolutionImageURL) {
            self.mediaURL = standardResolutionImageURL;
            self.downloadState = BLCMediaDownloadStateNeedsImage;
        } else {
            self.downloadState = BLCMediaDownloadStateNonRecoverableError; //URL for image is broken for some reason
        }
        
        NSDictionary *captionDictionary = mediaDictionary[@"caption"];
        
        // Caption might be null (if there's no caption)
        if ([captionDictionary isKindOfClass:[NSDictionary class]]) {
            self.caption = captionDictionary[@"text"];
        } else {
            self.caption = @"";
        }
        
        NSMutableArray *commentsArray = [NSMutableArray array];
        
        for (NSDictionary *commentDictionary in mediaDictionary[@"comments"][@"data"]) {
            BLCComment *comment = [[BLCComment alloc] initWithDictionary:commentDictionary];
            [commentsArray addObject:comment];
        }
        
        self.comments = commentsArray;
        
        BOOL userHasLiked = [mediaDictionary[@"user_has_liked"] boolValue]; //has the user already liked the picture on Instagram?
        
        self.likeState = userHasLiked ? BLCLikeStateLiked : BLCLikeStateNotLiked; //set animation/gfx flag accordingly
        
        
        self.likeNumber = [mediaDictionary[@"likes"][@"count"] integerValue]; //get number of likes upon loading for the first time
        
    }
    
    return self;
}

- (NSArray*) itemsToShare
{

    NSMutableArray* itemsToShare = [NSMutableArray new];

    if (self.caption.length > 0) {
        [itemsToShare addObject:self.caption];
    }

    if (self.image) {
        [itemsToShare addObject:self.image];
    }

    return itemsToShare;
}

#pragma mark - NSCoding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        self.idNumber = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(idNumber))];
        self.user = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(user))];
        self.mediaURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(mediaURL))];
        self.image = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(image))];
        
        if (self.image) {
            self.downloadState = BLCMediaDownloadStateHasImage; //we're good w/ image
        } else if (self.mediaURL) {
            self.downloadState = BLCMediaDownloadStateNeedsImage; //we've got an ok URL but no image yet
        } else {
            self.downloadState = BLCMediaDownloadStateNonRecoverableError; //URL is screwed up
        }
        
        self.caption = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(caption))];
        self.comments = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(comments))];
        self.likeState = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(likeState))];
        self.likeNumber = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(likeNumber))];
    }
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.idNumber forKey:NSStringFromSelector(@selector(idNumber))];
    [aCoder encodeObject:self.user forKey:NSStringFromSelector(@selector(user))];
    [aCoder encodeObject:self.mediaURL forKey:NSStringFromSelector(@selector(mediaURL))];
    [aCoder encodeObject:self.image forKey:NSStringFromSelector(@selector(image))];
    [aCoder encodeObject:self.caption forKey:NSStringFromSelector(@selector(caption))];
    [aCoder encodeObject:self.comments forKey:NSStringFromSelector(@selector(comments))];
    [aCoder encodeInteger:self.likeState forKey:NSStringFromSelector(@selector(likeState))];
    [aCoder encodeInteger:self.likeNumber forKey:NSStringFromSelector(@selector(likeNumber))];
}

@end
