//
//  RoomView.m
//  PathfinderPhone
//
//  Created by Igor Delovski on 22/10/2023.
//  Copyright © 2023 Igor Delovski. All rights reserved.
//

#import  "RoomView.h"

@implementation RoomView

- (id)initWithFrame:(CGRect)frame viewController:(ViewController *)viewCtrl
{
   if (self = [super initWithFrame:frame])  {
      self.parentViewController = viewCtrl;
      self.backgroundColor = [UIColor whiteColor];
      NSLog (@"RoomView: init");
   }
   
   return (self);
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
   [self.parentViewController.bobsGenome renderInView:self];
}

@end
