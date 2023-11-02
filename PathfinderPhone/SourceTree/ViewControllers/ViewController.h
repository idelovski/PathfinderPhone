//
//  ViewController.h
//  PathfinderPhone
//
//  Created by Igor Delovski on 22/10/2023.
//  Copyright © 2023 Igor Delovski. All rights reserved.
//

#import  <UIKit/UIKit.h>

#import  "BobsGenome.h"
#import  "BobsMap.h"

@interface ViewController : UIViewController

// @property (nonatomic, retain)  BobsMap      *bobsMap;
@property (nonatomic, retain)  BobsGenAlgo  *bobsGenome;

@end

