//
//  ImageBarButtonItem.m
//  FolderNav
//
//  Created by Morten Norby Larsen on 12/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageBarButtonItem.h"

//
// Provide a 40x40 bar button item with an image and a transparent 
// button, to make a Mail-like button bar.
//
// In order to get a UIBarButtonItem with an image, a trick is necessary:
// 
// 1. Make an empty view
// 2. Make an image view to hold the image
// 3. Make a blank button with a target and an action, like any button
// 4. Add the image view and the button to the custom view
// 5. Make the bar button item with the custom view
//

@implementation ImageBarButtonItem {
    UIView *customView;
    UIButton *button;
    UIImage *itemImage;
    UIImageView *itemImageView;
}




// This class has its own initializer - it is the only one for 
// the class, so it is also its designated initializer.
//
- (id)initWithImageName:(NSString *)imageName target:(id)target action:(SEL)action
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    
    self = [super initWithCustomView:view];
    if (self) {
        
        customView = view;
        
        button = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 40, 40)];
        button.showsTouchWhenHighlighted = YES;
        
        [button addTarget:target action: action forControlEvents:UIControlEventTouchUpInside];
        
        itemImage = [UIImage imageNamed: imageName];
        
        itemImageView = [[UIImageView alloc] initWithImage: itemImage];
        itemImageView.frame = CGRectMake(8, 8, 24, 24);
        
        [customView addSubview:itemImageView];
        [customView addSubview:button];        
    }
    return self;
}


- (void) setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    if (enabled) {
        itemImageView.alpha = 1.0f;
    }
    else {
        itemImageView.alpha = 0.3;
    }
}

@end
