//
//  ViewController.m
//  PathfinderPhone
//
//  Created by Igor Delovski on 22/10/2023.
//  Copyright © 2023 Igor Delovski. All rights reserved.
//

#import  "ViewController.h"

#import  "RoomView.h"

@interface ViewController ()

@end

@implementation ViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
   if (self = [super initWithCoder:aDecoder])  {
      self.view = [[RoomView alloc] initWithFrame:CGRectZero viewController:self];
      // self.bobsMap = [[BobsMap alloc] init];
      self.bobsGenome = [[BobsGenAlgo alloc] initWithCrossoverRate:kCrossoverRate
                                                      mutationRate:kMutationRate
                                                           popSize:kPopulationSize
                                                      chromoLength:kCromosomeLength
                                                        geneLength:2];
      self.allSetup = NO;
      
      [NSTimer scheduledTimerWithTimeInterval:0.016666666667
                                       target:self selector:@selector(engineLoop:)
                                     userInfo:nil
                                      repeats:YES]; 
      
      NSLog (@"ViewController: initWithCoder:");
   }
   
   return (self);
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   // Do any additional setup after loading the view.
}

- (void)viewDidLayoutSubviews
{
   [super viewDidLayoutSubviews];
   
   [self.bobsGenome run];
   
   [self.bobsGenome epochLoop];
   
   [self.view setNeedsDisplay];

   self.allSetup = YES;
}

#pragma mark -

- (void)engineLoop:(id)info
{
   if (self.allSetup)  {
      if ([self.bobsGenome started])  {
         [self.bobsGenome epochLoop];
         [self.view setNeedsDisplay];
      }
   }
}

@end
