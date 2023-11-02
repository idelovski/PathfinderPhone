//
//  RoomView.h
//  PathfinderPhone
//
//  Created by Igor Delovski on 22/10/2023.
//  Copyright © 2023 Igor Delovski. All rights reserved.
//

#import  <UIKit/UIKit.h>

#import  "ViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface RoomView : UIView

@property  (nonatomic, weak)  ViewController  *parentViewController; 

- (id)initWithFrame:(CGRect)frame viewController:(ViewController *)viewCtrl;

@end

NS_ASSUME_NONNULL_END
