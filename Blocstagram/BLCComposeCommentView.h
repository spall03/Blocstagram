//
//  BLCComposeCommentView.h
//  Blocstagram
//
//  Created by Stephen Palley on 1/2/15.
//  Copyright (c) 2015 Steve Palley. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLCComposeCommentView;

@protocol BLCComposeCommentViewDelegate <NSObject>

- (void) commentViewDidPressCommentButton:(BLCComposeCommentView *)sender;
- (void) commentView:(BLCComposeCommentView *)sender textDidChange:(NSString *)text;
- (void) commentViewWillStartEditing:(BLCComposeCommentView *)sender;

@end

@interface BLCComposeCommentView : UIView

@property (nonatomic, weak) NSObject <BLCComposeCommentViewDelegate> *delegate;
@property (nonatomic, assign) BOOL isWritingComment; //is the user editing comment field?
@property (nonatomic, strong) NSString *text; //text of the comment

- (void) stopComposingComment; //controller decides to cancel comment and put away keyboard


@end
