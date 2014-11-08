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
        
        //Init amount
        self.amount = 0;
        
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
#ifdef DEBUG
            NSLog(@"Cell recursive description:\n\n%@\n\n", [self performSelector:@selector(recursiveDescription)]);
#endif
            CGPoint translation = [recognizer translationInView:self.swipeContentView];
            // Since we have added the recognizer to the swipContentView above, we can access the view from the recognizer
            // via it's view property.
            recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y);
            // This line resets the translation of the recognizer every time the Began state is triggered.
            [recognizer setTranslation:CGPointMake(0, 0) inView:self.swipeContentView];
            
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
            
            [self numberViewTrigger];
            
            if (self.numberView) {
                self.numberView.text = [[NSNumber numberWithInt:self.amount += 1] stringValue];
            }
            
        }
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"Pan gesture ended.");
#ifdef DEBUG
            NSLog(@"Cell recursive description:\n\n%@\n\n", [self performSelector:@selector(recursiveDescription)]);
#endif
            // Check for trigger point.
            [self calculateTrigger];
            
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
    // If the swipe is not greater than or equal to the a 40% this will allow the user to cancel what they want to do.
    if (currentSwipPercentage <= 40.0) {
        NSLog(@"Cancel trigger point.");
        
        /*
         *  The below animation logic chains the animations we want to do when the user 'cancels' their swipe.
         *  The first animations slides the view aback to its original position.
         *  The second animation(inside the first animation's completion block) gives the return animation a little bounce by sliding it in the opposite direction 1 point.
         The third (inside the seconf animation's completion block) animation does the same thing as the first and animates the view back to its original position.
         */
        [UIView animateWithDuration:0.2 animations:^{
            NSLog(@"Returning animation");
            
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            
            // Use the frame of the super view because its frame contains the original position we want
            // to set the final position of the swipeContentView
            self.panRecognizer.view.frame = self.panRecognizer.view.superview.frame;
            
        } completion: ^(BOOL finished){
            // Completion block of the first animation
            
            
            [UIView animateWithDuration:0.2 animations:^{
                NSLog(@"Returning animation");
                
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                
                // This will be the final destination of the bounce animation. It's the same as its original postioin plus one point on hte x-axis.
                self.panRecognizer.view.frame = CGRectMake(self.panRecognizer.view.superview.frame.origin.x + 1,
                                                           self.panRecognizer.view.superview.frame.origin.y,
                                                           self.panRecognizer.view.frame.size.width,
                                                           self.panRecognizer.view.frame.size.height);
                
            } completion: ^(BOOL finished){
                // Completion block of the second animation.
                
                NSLog(@"Returning animation");
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.2];
                [UIView setAnimationDelay:0];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                
                // Use the frame of the super view because it's frame contains the original position we want
                // to set the final position of the swipeContentView
                self.panRecognizer.view.frame = self.panRecognizer.view.superview.frame;
                
            }];
        }];
        
    } else {
        NSLog(@"Apply swipe action trigger point.");
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelay:0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        self.panRecognizer.view.frame = CGRectMake(self.panRecognizer.view.superview.frame.size.width,
                                                   self.panRecognizer.view.superview.frame.origin.y,
                                                   self.panRecognizer.view.frame.size.width,
                                                   self.panRecognizer.view.frame.size.height);
        [UIView commitAnimations];
    }
}

-(void)numberViewTrigger
{
    NSLog(@"Calculating display view trigger point.");
    // Formula for caluclating the percentages is: current x coordinate of the view's origin divided by the width.
    CGFloat currentSwipePercentage = (((self.panRecognizer.view.frame.origin.x / (self.panRecognizer.view.frame.size.width)) * 100));
    NSLog(@"Current swipe percentage: %f", currentSwipePercentage);
    
    // Logic to decide what the trigger points are.
    // If the swipe is not greater than or equal to the a 40% this will allow the user to cancel what they want to do.
    if (currentSwipePercentage <= 40.0) {
        NSLog(@"Remove number view trigger point.");
        // Remove number view from superview.
        [self.numberView removeFromSuperview];
        
        // Reset the number view.
        self.numberView.text = [[NSNumber numberWithInt:0] stringValue];
    } else {
        
        // We only want to create the view if one doesn't already exist.
        // Since this method is being called when the pan state has changed, it would create a view each time this event is fired.
        if (!self.numberView) {
            self.numberView = [[UILabel alloc] initWithFrame:CGRectMake(self.panRecognizer.view.superview.frame.origin.x,
                                                                        self.panRecognizer.view.superview.frame.origin.y,
                                                                        self.panRecognizer.view.frame.size.width / 3,
                                                                        self.panRecognizer.view.frame.size.height)];
            [self.numberView setBackgroundColor:[UIColor greenColor]];
            
            // Initialize the counter with self.amount.
            self.numberView.text = [[NSNumber numberWithInt:self.amount] stringValue];
            
            NSLog(@"Adding numnber view as a subview to the swipeContentView");
            // Create the number view
            [self.swipeContentView.superview addSubview:self.numberView];
        } else {
            // If an instance of the numberView already exists we just want to add as a sub view.
            // This covers the case where the user swiped passed the trigger point then went back but decide to go
            // back again.
            [self.swipeContentView.superview addSubview:self.numberView];
        }
        
        
    }
}

@end
