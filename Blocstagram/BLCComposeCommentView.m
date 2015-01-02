//
//  BLCComposeCommentView.m
//  Blocstagram
//
//  Created by Stephen Palley on 1/2/15.
//  Copyright (c) 2015 Steve Palley. All rights reserved.
//

#import "BLCComposeCommentView.h"

@interface BLCComposeCommentView () <UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *button;

@end

@implementation BLCComposeCommentView


//initialization in the correct position
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.textView = [UITextView new];
        self.textView.delegate = self;
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.button setAttributedTitle:[self commentAttributedString] forState:UIControlStateNormal];
        [self.button addTarget:self action:@selector(commentButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.textView];
        [self.textView addSubview:self.button];
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    self.textView.frame = self.bounds;
    
    if (self.isWritingComment) {
        self.textView.backgroundColor = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1]; /*#eeeeee*/
        self.button.backgroundColor = [UIColor colorWithRed:0.345 green:0.318 blue:0.424 alpha:1]; /*#58516c*/
        
        CGFloat buttonX = CGRectGetWidth(self.bounds) - CGRectGetWidth(self.button.frame) - 20; //button scoots to the right side of the view
        self.button.frame = CGRectMake(buttonX, 10, 80, 20);
    } else {
        self.textView.backgroundColor = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1]; /*#e5e5e5*/
        self.button.backgroundColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1]; /*#999999*/
        
        self.button.frame = CGRectMake(10, 10, 80, 20); //button scoots to the left side of the view
    }
    
    CGSize buttonSize = self.button.frame.size;
    buttonSize.height += 20;
    buttonSize.width += 20;
    CGFloat blockX = CGRectGetWidth(self.textView.bounds) - buttonSize.width; //right-hand position
    CGRect areaToBlockText = CGRectMake(blockX, 0, buttonSize.width, buttonSize.height);
    UIBezierPath *buttonPath = [UIBezierPath bezierPathWithRect:areaToBlockText];
    
    self.textView.textContainer.exclusionPaths = @[buttonPath]; //wraps text around the button when it's on the right-hand size of the view
}



- (void) stopComposingComment {
    [self.textView resignFirstResponder];
}

//make button text look cool
- (NSAttributedString *) commentAttributedString {
    NSString *baseString = NSLocalizedString(@"COMMENT", @"comment button text");
    NSRange range = [baseString rangeOfString:baseString];
    
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] initWithString:baseString];
    
    [commentString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10] range:range];
    [commentString addAttribute:NSKernAttributeName value:@1.3 range:range]; //increase char spacing
    [commentString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1] range:range];
    
    return commentString;
}

//user enters text
- (void) setText:(NSString *)text {
    _text = text;
    self.textView.text = text; //update view with text
    self.textView.userInteractionEnabled = YES;
    self.isWritingComment = text.length > 0; //user is writing a comment currently
}

#pragma mark - Setters & Getters

- (void) setIsWritingComment:(BOOL)isWritingComment {
    [self setIsWritingComment:isWritingComment animated:NO];
}

//animated call for switching button position
- (void) setIsWritingComment:(BOOL)isWritingComment animated:(BOOL)animated {
    _isWritingComment = isWritingComment;
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            [self layoutSubviews];
        }];
    } else {
        [self layoutSubviews];
    }
}

#pragma mark - Button Target

- (void) commentButtonPressed:(UIButton *) sender {
    if (self.isWritingComment) { //user finished writing comment
        [self.textView resignFirstResponder]; //keyboard dismissed
        self.textView.userInteractionEnabled = NO; //can't edit
        [self.delegate commentViewDidPressCommentButton:self]; //send to Instagram
    } else { //user wants to write comment
        [self setIsWritingComment:YES animated:YES]; //move button over
        [self.textView becomeFirstResponder]; //bring up keyboard
    }
}

#pragma mark - UITextViewDelegate

//can user edit text?
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [self setIsWritingComment:YES animated:YES];
    [self.delegate commentViewWillStartEditing:self];
    
    return YES;
}

//called when user types stuff to update text in text field
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    [self.delegate commentView:self textDidChange:newText];
    return YES;
}

//was a comment entered?
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    BOOL hasComment = (textView.text.length > 0);
    [self setIsWritingComment:hasComment animated:YES];
    
    return YES;
}

@end
