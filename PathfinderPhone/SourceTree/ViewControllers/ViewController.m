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
   
   [self crateUIObjects];
}

- (void)viewDidLayoutSubviews
{
   [super viewDidLayoutSubviews];
   
   [self placeUIObjects];

   [self.bobsGenome run];
   
   [self.bobsGenome epochLoop];
   
   [self.view setNeedsDisplay];

   self.allSetup = YES;
}

#pragma mark -

- (void)onClick:(id)sender forEvent:(UIEvent *)event
{
   if ([self.bobsGenome started])
      [self.bobsGenome stop];
   else
      [self.bobsGenome run];

   NSLog (@"Touch events goes here");
}

- (void)crateUIObjects
{
   if (!self.generationLabel && self.view)  {
      self.generationLabel = [[UILabel alloc] initWithFrame:CGRectZero];   // Label
      
      self.generationLabel.textAlignment = NSTextAlignmentCenter;
      
      self.generationLabel.text = @"Generation: 0";
      [self.view addSubview:self.generationLabel];
   }

   if (!self.startButton && self.view)  {
      self.startButton = [[UIButton alloc] initWithFrame:CGRectZero];   // Button
      
      [self.startButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
      [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
      [self.startButton addTarget:self action:@selector(onClick:forEvent:) forControlEvents:UIControlEventTouchUpInside];
      [self.view addSubview:self.startButton];
   }
}

- (void)placeUIObjects
{
   CGRect  viewRect = self.view.frame;
   CGRect  tmpRect = CGRectInset (viewRect, 32., 32.);

#ifdef _ONE_DAY_
   AppDelegate  *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
   
   if (appDelegate.edgeInsets.top > statusHeight)
      topOffset = appDelegate.edgeInsets.top - statusHeight;
#endif
   
   [self crateUIObjects];  // Just in case we failed to create them before
   
   // Label
   tmpRect.size.height = 30.;
   self.generationLabel.frame = tmpRect;
   
   // Button
   tmpRect = CGRectInset (viewRect, 32., 32.);
   tmpRect.origin.y = tmpRect.size.height + 8;
   tmpRect.size.height = 30.;
   self.startButton.frame = tmpRect;
}

#pragma mark -

- (void)engineLoop:(id)info
{
   if (self.allSetup)  {
      if ([self.bobsGenome started])  {
         [self.bobsGenome epochLoop];
         [self.view setNeedsDisplay];
         [self.startButton setTitle:@"Stop" forState:UIControlStateNormal];
         self.generationLabel.text = [NSString stringWithFormat:@"Generation: %d", self.bobsGenome.generation];
      }
      else
         [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
   }
}

@end
