# Creating a swipeable table view cell in iOS.

These are some notes on how I created a swiping table cell for iOS, made popular by the awesome Mailbox app. Here's what I did:

Create your own ``UITableViewController``.

Change the number of sections to return one and the number of rows to return the same.

## Creating the swiping cell.

Create your own Cell class (``SwipeViewCell``) for your swiping cell. This class will inherit from ``UITableViewCell``.

Import your custom cell header file into the your new tableview controller. Place ``#import "SwipeViewCell.h"`` at the top of the controller's implementation file.

Change the ``tableView:cellForRowAtIndexPath:`` method to look something like this:


```objective-c
SwipeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwipeCell"];

    // Configure the cell...
    // If the cell doesn't exist then initialize one with the correct identifier.
    if (!cell) {
        cell = [[SwipeViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SwipeCell"];
    }


    // This log statement wil print a tree structure of the view hierarchy of the cell.
#ifdef DEBUG
    NSLog(@"Cell recursive description:\n\n%@\n\n", [cell performSelector:@selector(recursiveDescription)]);
#endif

    return cell;
```


The log statement will print out a hierarchical tree structure of the cell's views. Here is an exmaple:

```
<SwipeViewCell: 0xb989560; baseClass = UITableViewCell; frame = (0 0; 320 44); layer = <CALayer: 0xb989820>>
   | <UITableViewCellContentView: 0xb989d40; frame = (0 0; 320 44); gestureRecognizers = <NSArray: 0xb98a600>; layer = <CALayer: 0xb989e90>>
```

At this point everything should work as normal, and we're all setup to start creating our swiping cell. Any customisation that needs to be done to a cell should be done in the cell's content view according to the iOS documentation.

We are going to create a new ``UIView`` view inside the cell's ``contentView`` to hold all the content we want to see moving across the cell.

Inside the ``initWithStyle:reuseIdentifier:`` method add these lines of code:

```objective-c
// Add a subView to hold our content that will be swiped.
// Create a UIView that is the same width, height, and origin as the cell's content view
self.swipeContentView = [[UIView alloc] initWithFrame:self.contentView.frame];
[self.contentView addSubview:self.swipeContentView];
```

As you can see, we are adding the `swipeContentView` to the cell's `contentView`. Importantly, our `swipeContentView` will cover the cell's `contentView` because we are setting it's frame to be the same as the `contentView`.

Now lets have another look at the view hierarchy:

```
<SwipeViewCell: 0xb989560; baseClass = UITableViewCell; frame = (0 0; 320 44); layer = <CALayer: 0xb989820>>
   | <UITableViewCellContentView: 0xb989d40; frame = (0 0; 320 44); gestureRecognizers = <NSArray: 0xb98a600>; layer = <CALayer: 0xb989e90>>
   |    | <UIView: 0xb98a650; frame = (0 0; 320 44); layer = <CALayer: 0xb98a6c0>>
```

You can see our view has been added to the ``UITableViewCellContentView``.

A cell, is itself a view. This means that it can have a background color. We are going to set a background color for the cell's ``contentView`` (our ``swipeContentView``).

Add a background color to the cell's ``contentView`` then add one for our ``swipeContentView``:

```objective-c
// Adding color to the content view to make the layers distinguishable.
[self.contentView setBackgroundColor:[UIColor blueColor]];
// Add color to the swipe content view.
[self.swipeContentView setBackgroundColor:[UIColor redColor]];
```

Adding these colours will allow us to see the swiping in action. We will only see the red color covering the cell, but when we start swiping it will reveal the blue color.

## Adding the pan gesture.

To add a pan gesture recognizer to our `swipeContentView` I added the following lines of code to the `initWithStyle:reuseIdentifier:` method:

```objective-c
// Initialize the pan gesture recognizer.
// This initializes a UIPanGestureRecognizer where the target is this cell instance where
// the panning action is handled with the panThisCell method
UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panThisCell:)];
// Set the recognizer delegate to this cell's instance
panRecognizer.delegate = self;
// Adding the recognizer to our swipeContentView
[self.swipeContentView addGestureRecognizer:panRecognizer];
```

Now we have to implement the `panThisCell` method. This is where we'll handle any logic during the animation. First, log the pan gesture translation. This is the x, y coordinate of the user's finger as it pans across the cell relative to where it touched the screen. The initial point will be (0,0) and will change as the user moves their finger. Your method should look something like this:
```objective-c
// This method is the handler for the pan gesture we added to the swipeContentView.
// It takes, as a parameter, the instance of the pan gesture recognizer.
- (void)panThisCell:(UIPanGestureRecognizer *)recognizer
{
    // This point represents where the position of the user's finger is relative to where the pan began.
    CGPoint panPoint = [recognizer translationInView:self.swipeContentView];
    NSLog(@"Pan position relative to it's start point: %@", NSStringFromCGPoint(panPoint));
}
```

Now if we have another look at the view hierarchy, you will see our `swipeContentView` has `gestureRecognizers` associated with it.

```
<SwipeViewCell: 0xaf37980; baseClass = UITableViewCell; frame = (0 0; 320 44); layer = <CALayer: 0xaf37c40>>
   | <UITableViewCellContentView: 0xaf38160; frame = (0 0; 320 44); gestureRecognizers = <NSArray: 0xaf38a40>; layer = <CALayer: 0xaf382b0>>
   |    | <UIView: 0xaf38a90; frame = (0 0; 320 44); gestureRecognizers = <NSArray: 0xaf38ea0>; layer = <CALayer: 0xaf38b00>>
```

A pan gesture has three important states (there are more but we are not going to worry about them for now, you can find more by looking at the iOS documentation) `UIGestureRecognizerStateBegan`, `UIGestureRecognizerStateChanged`, and `UIGestureRecognizerStateEnded`.

When a user starts the pan it has a state of `UIGestureRecognizerStateBegan`, when the swipe continues it has a state of `UIGestureRecognizerStateChanged`, and when the user stops and removes their finger from the screen it has a state of `UIGestureRecognizerStateEnded`.

Here is the code to handle the states:

```objective-c
// This method is the handler for the pan gesture we added to the swipeContentView.
// It takes, as a parameter, the instance of the pan gesture recognizer.
- (void)panThisCell:(UIPanGestureRecognizer *)recognizer
{
    // This point represents where the position of the user's finger is relative to where the pan began.
    CGPoint panPoint = [recognizer translationInView:self.swipeContentView];
    NSLog(@"Pan position relative to it's start point: %@", NSStringFromCGPoint(panPoint));

    // Here we handle the three states we are looking for.
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"Pan Gesture began.");
            break;
        case UIGestureRecognizerStateChanged:
            NSLog(@"Pan Gesture changed.");
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"Pan gesture ended.");
            break;
        default:
            NSLog(@"Pan gesture unknown behaviour");
            break;
    }
}
```

## Adding the swiping animation.

Next we have to implement some logic to change the position of our `swipeContentView` as it moves across the cell.
Our `swipeContentView` has a center property of type `CGPoint` that allows us to change the center position of the view.
To do this we need to add the the value of the x coordinate of the translation to the x coordinate of the center of the `swipeContentView`.
However, just doing this action alone will cause strange behaviour.
Our `swipeContentView` won't move linearly across the cell because it just adds the translation value to the center of the view.
Imagine if the translation was (10,0), it would add 10 to the x coordinate of the center of the `swipeContentView` and then the translation changes to (11,0) as the users keeps swiping, now 11 will be added to the center of the view.
We need to reset the translation of the view after we update the center position, this means that the translation will be reset to (0,0) and then once the swipe changes again it will only add the next point.

Our switch statement will look like this now:
```objective-c
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
        }
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"Pan gesture ended.");
            break;
        default:
            NSLog(@"Pan gesture unknown behaviour");
            break;
    }
```

## Adding the swiping triggers (or events).

This is cool swiping over and back doing nothing.. But what we really want is to trigger an action when we do the swipe.
To do this we need to decide at what point along the width of the cell to trigger an action.
First we need to determine how far the `swipeContentView` has travelled in percent.
The X coordinate of the the view's origin relative to the width of the view will give us the percentage.
Once we have the percentage, all we need is to decide what will trigger a certain action.
Implement the `calculateTrigger` method below.

```objective-c
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
```

You should note that we do not pass the `recognizer` as a parameter to this method.
This is because we need to change the recognizer so that it's an instance variable. Add the recognizer as a property in the header file of the `SwipeCell`.
```objective-c
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
```

Now, anytime you refer to the `panRecognizer` use `self.panRecognizer`.

We need to call this method when the pan recognizer's state changes and/or begins.

```objective-c
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
```
At the moment our swiping doesn't do much apart from log a few things but that's okay because we're going to tidy up the animation a little and trigger an action.
When a user doesn't swipe far enough and ends the swipe we want the app to slide the `swipeContentView` back to its original position, and when it's swiped far enough, we want to complete the swipe by animating the view to the end.
To do this we need to add some animation logic to the `calculteTrigger` method. The iOS API offers a really nice approach to doing animations. We need to refactor the method to look something like this:

You'll note that I have changed the logic of the if statement slightly as well. As I was writing this the code was evolving at the same time.

```objective-c
-(void)calculateTrigger
{
    NSLog(@"Calculating trigger point.");
    // Formula for caluclating the percentages is: current x coordinate of the view's origin divided by the width.
    CGFloat currentSwipPercentage = (((self.panRecognizer.view.frame.origin.x / (self.panRecognizer.view.frame.size.width)) * 100));
    NSLog(@"Current swipe percentage: %f", currentSwipPercentage);

    // Logic to decide what the trigger points are.
    // If the swipe is not greater than or equal to the a 25% this will allow the user to cancel what they want to do.
    if (currentSwipPercentage <= 40.0) {
        NSLog(@"Cancel trigger point.");


        // Animation setup.
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelay:0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];

        // Use the frame of the super view because its frame contains the original position we want
        // to set the final position of the swipeContentView
        self.panRecognizer.view.frame = self.panRecognizer.view.superview.frame;

        [UIView commitAnimations];
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
```

Some explanation on the two parts above.
When a user 'cancels' a swipe we want the final destination of the return animation to be the same position as the parent view since it hasn't moved at all.
Thats why we are using the parent view's frame.
The second part of the if statement will complete the swipe. We want the frame to start at the end of the cell where the x coordinate of the origin is the same as the length of the cell.

Our swiping animation is becoming more and more polished, but we can make it look even slicker by adding a small bounce animation to the return animation.
Doing this requires a little more understanding about how the UIView animations work.
If we define multiple animations using the begin/commit syntax like above then they would all be executed at the same time.
To have them run sequentially we need to define them in a block-based fashion.
When defining animations in this way there is a completion block parameter that will allow us to perform the next animation. This block is only executed when the animation it is defined in has completed.


Check out the code snippet below. You will see in the code the changes we've made to run our animations one after another.
```objective-c
// Logic to decide what the trigger points are.
// If the swipe is not greater than or equal to the a 40% this will allow the user to cancel what they want to do.
if (currentSwipPercentage <= 40.0) {
    NSLog(@"Cancel trigger point.");

    /*
     *  The below animation logic chains the animations we want to do when the user 'cancels' their swipe.
     *  The first animations slides the view aback to its original position.
     *  The second animation(inside the first animation's completion block) gives the return animation a little bounce by sliding it in the opposite direction 1 point.
        The third (inside the second animation's completion block) animation does the same thing as the first and animates the view back to its original position.
     */
    [UIView animateWithDuration:0.2 animations:^{
        NSLog(@"Returning animation");

        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];

        // Use the frame of the super view because it's frame contains the original position we want
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

        }];œ
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
```

Lets add a view that contains a number that increases or decreases as the user swipes his/her finger across the table cell. To accomplish this we want to add a subview to the `contentView` of the `UITableViewCellContentView`. We need some way to calculate at what point to add this view during the swipe. Considering we already have some functionality similar to this in the `calculateTrigger` mehtod we can create a new method specifically for our new number view. Below, I have implemented a method that does the same trigger point check and then adds the new number sub view.

```objective-c
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
    } else {

        // We only want to create the view if one doesn't already exist.
        // Since this method is being called when the pan state has changed, it would create a view each time this event is fired.
        if (!self.numberView) {
            self.numberView = [[UIView alloc] initWithFrame:CGRectMake(self.panRecognizer.view.superview.frame.origin.x,
                                                                       self.panRecognizer.view.superview.frame.origin.y,
                                                                       self.panRecognizer.view.frame.size.width / 3,
                                                                       self.panRecognizer.view.frame.size.height)];
            [self.numberView setBackgroundColor:[UIColor greenColor]];

            NSLog(@"Adding numnber view as a subview to the swipeContentView");
            // Create the number view
            [self.swipeContentView.superview addSubview:self.numberView];
        } else {
            [self.swipeContentView.superview addSubview:self.numberView];
        }


    }
}
```
We need to call this method when the `UIGestureRecognizerStateChanged` event is fired.

```objective-c
case UIGestureRecognizerStateChanged:{
    NSLog(@"Pan Gesture changed.");
    CGPoint translation = [recognizer translationInView:self.swipeContentView];
    // Since we have added the recognizer to the swipContentView above, we can access the view from the recognizer
    // via it's view property.
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y);
    // This line resets the translation of the recognizer every time the Changed state is triggered.
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.swipeContentView];

    [self numberViewTrigger];

}
```
As you might have noticed by now there is some duplication between the `calculateTrigger` and `numberViewTrigger` methods. A nice way to refactor this would be to create one method that accepts two blocks; one for the happy path of the if statement that checks the trigger point, and the other for the sad path. We'll do this later.
