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


@interface BLCDataSource ()

@property (nonatomic, strong) NSMutableArray *mediaItems; //this obj (.self) can modify array

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

- (instancetype) init
{
    self = [super init];
    
    if (self) {
        [self addRandomData];
    }
    
    return self;
}

- (void) addRandomData
{
    NSMutableArray *randomMediaItems = [NSMutableArray array]; //to hold all our media
    
    for (int i = 1; i <= 10; i++) //loop through pics
    {
        NSString *imageName = [NSString stringWithFormat:@"%d.jpg", i];
        UIImage *image = [UIImage imageNamed:imageName]; //assign pic a name and put it in a UIImage
        
        if (image)
        {
            BLCMedia *media = [[BLCMedia alloc] init];
            media.user = [self randomUser]; //add a random user
            media.image = image; //add image to media object
            NSUInteger wordCount = arc4random_uniform(20);
            media.caption = [self randomSentence:wordCount]; //multi-word random caption
            
            NSUInteger commentCount = arc4random_uniform(10);
            NSMutableArray *randomComments = [NSMutableArray array];
            
            for (int i  = 0; i <= commentCount; i++)
            {
                BLCComment *randomComment = [self randomComment]; //generate random comments
                [randomComments addObject:randomComment];
            }
            
            media.comments = randomComments; //add comments to media object
            
            [randomMediaItems addObject:media]; //add media w/ associated info to media list
        }
    }
    
    self.mediaItems = randomMediaItems; //core data object
}


- (BLCUser *) randomUser
{
    BLCUser *user = [[BLCUser alloc] init];
    
    user.userName = [self randomStringOfLength:arc4random_uniform(10)]; //random user name for user
    
    NSString *firstName = [self randomStringOfLength:arc4random_uniform(7)];
    NSString *lastName = [self randomStringOfLength:arc4random_uniform(12)];
    user.fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName]; //random full name for user
    
    return user;
}

- (BLCComment *) randomComment
{
    BLCComment *comment = [[BLCComment alloc] init];
    
    comment.from = [self randomUser]; //pick random user to have created comment
    
    NSUInteger wordCount = arc4random_uniform(20);
    
    comment.text = [self randomSentence:wordCount];
    
    return comment;
}

- (NSString *) randomSentence:(NSUInteger) wordCount
{
    
    NSMutableString *randomSentence = [[NSMutableString alloc] init];
    
    for (int i  = 0; i <= wordCount; i++)
    {
        NSString *randomWord = [self randomStringOfLength:arc4random_uniform(12)];
        [randomSentence appendFormat:@"%@ ", randomWord]; //generate gibberish
    }
    
    
    return randomSentence;
}

- (NSString *) randomStringOfLength:(NSUInteger) len
{
    NSString *alphabet = @"abcdefghijklmnopqrstuvwxyz";
    
    NSMutableString *s = [NSMutableString string];
    for (NSUInteger i = 0U; i < len; i++)
    {
        u_int32_t r = arc4random_uniform((u_int32_t)[alphabet length]);
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c]; //pick random letters out of alphabet
    }
    return [NSString stringWithString:s];
}

@end
