//
//  SwipeViewCell.m
//  SwipeCell
//
//  Created by Karl Grogan on 13/09/2014.
//  Copyright (c) 2014 Karl Grogan. All rights reserved.
//

#import "SwipeViewCell.h"

@implementation SwipeViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        // Add a subView to hold our content that will be swiped.
        // Create a UIView that is the same width, height, and origin as the cell's content view
        self.swipeContentView = [[UIView alloc] initWithFrame:self.contentView.frame];
        [self.contentView addSubview:self.swipeContentView];
        
        // Some logging output
        // Adding color to the content view to make the layers distinguishable.
        [self.contentView setBackgroundColor:[UIColor blueColor]];
        // Add color to the swipe content view.
        [self.swipeContentView setBackgroundColor:[UIColor redColor]];
        
        // Initialize the pan gesture recognizer.
        // This initializes a UIPanGestureRecognizer where the target is this cell instance where
        // the panning action is handled with the panThisCell method
        self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panThisCell:)];
        // Set the recognizer delegate to this cell's instance
        self.panRecognizer.delegate = self;
        // Adding the recognizer to our swipeContentView
        [self.swipeContentView addGestureRecognizer:self.panRecognizer];

    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// This method is the handler for the pan gesture we added to the swipeContentView.
// It takes, as a parameter, the instance of the pan gesture recognizer.
- (void)panThisCell:(UIPanGestureRecognizer *)recognizer
{
    // This point represents where the position of the user's finger is relative to where the pan began.
    CGPoint panPoint = [recognizer translationInView:self.swipeContentView];
    NSLog(@"Pan position relative to it's start point: %@", NSStringFromCGPoint(panPoint));
    
    // Here we handle the three states we are looking for.
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:{
            NSLog(@"Pan Gesture began.");
            CGPoint translation = [recognizer translationInView:self.swipeContentView];
            // Since we have added the recognizer to the swipContentView above, we can access the view from the recognizer
            // via it's view property.
            recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y);
            // This line resets the translation of the recognizer every time the Began state is triggered.
            [recognizer setTranslation:CGPointMake(0, 0) inView:self.swipeContentView];
            
            // Check for trigger point.
            [self calculateTrigger];
        }
            break;
        case UIGestureRecognizerStateChanged:{
            NSLog(@"Pan Gesture changed.");
            CGPoint translation = [recognizer translationInView:self.swipeContentView];
            // Since we have added the recognizer to the swipContentView above, we can access the view from the recognizer
            // via it's view property.
            recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y);
            // This line resets the translation of the recognizer every time the Changed state is triggered.
            [recognizer setTranslation:CGPointMake(0, 0) inView:self.swipeContentView];
            
            // Check for trigger point.
            [self calculateTrigger];
        }
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"Pan gesture ended.");
            break;
        default:
            NSLog(@"Pan gesture unknown behaviour");
            break;
    }
}

-(void)calculateTrigger
{
    
    NSLog(@"Calculating trigger point.");
    // Formula for caluclating the percentages is: current x coordinate of the view's origin divided by the width.
    CGFloat currentSwipPercentage = (((self.panRecognizer.view.frame.origin.x / (self.panRecognizer.view.frame.size.width)) * 100));
    NSLog(@"Current swipe percentage: %f", currentSwipPercentage);
    
    // Logic to decide what the trigger points are.
    // If the swip is not greater than or equal to the a 25% this will allow the user to cancel what they want to do.
    if (currentSwipPercentage >= 25.0 && currentSwipPercentage <= 49.0) {
        NSLog(@"Cancel trigger point.");
    } else if (currentSwipPercentage >= 50.0 && currentSwipPercentage <= 99.0) {
        NSLog(@"Apply swipe action trigger point.");
    }
}

@end
