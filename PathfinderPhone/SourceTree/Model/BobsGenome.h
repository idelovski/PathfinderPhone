//
//  BobsGenome.h
//  PathfinderPhone
//
//  Created by Igor Delovski on 24/10/2023.
//  Copyright © 2023 Igor Delovski. All rights reserved.
//

#import  <UIKit/UIKit.h>
            
#import  "BobsMap.h"

#define  kCrossoverRate      .7
#define  kMutationRate       .001
#define  kPopulationSize  140.
#define  kCromosomeLength  70.

NS_ASSUME_NONNULL_BEGIN

typedef enum  _BobMoves
{
   kBobMoveNorth  = 0,
   kBobMoveSouth,
   kBobMoveEast,
   kBobMoveWest
} BobMoves;

typedef struct  _Vector
{
   int  *vec;
   int   length;
} Vector;

@interface  Genome : NSObject

@property  (nonatomic, assign)  Vector  vector;
@property  (nonatomic, assign)  double  fitness;

- (id)initWithGeneLength:(int)geneLen;

- (void)clear;                 // memset(vec, 0, sizeof(int) * length);

+ (int)randomIntFrom:(int)from to:(int)to;
+ (double)randomFloat;

@end

@interface BobsGenAlgo : NSObject

@property  (nonatomic, strong)  NSMutableArray  *genomesArray;  // m_vecGenomes

@property  (nonatomic, assign)  int     populationSize;  // m_iPopSize, size of population

@property  (nonatomic, assign)  double  crossoverRate;  // m_dCrossoverRate
@property  (nonatomic, assign)  double  mutationRate;  // m_dMutationRate

@property  (nonatomic, assign)  int     chromoLength;  // m_iChromoLength, how many bits per chromosome
@property  (nonatomic, assign)  int     geneLength;    // m_iGeneLength, how many bits per gene
@property  (nonatomic, assign)  int     fittestGenome;  // m_iFittestGenome

@property  (nonatomic, assign)  double  bestFitnessScore;  // m_dBestFitnessScore
@property  (nonatomic, assign)  double  totalFitnessScore;  // m_dTotalFitnessScore

@property  (nonatomic, assign)  BOOL  busy;  // m_bBusy, lets you know if the current run is in progress.
@property  (nonatomic, assign)  int   generation;  // m_iGeneration

@property  (nonatomic, strong)  BobsMap  *bobsMap;  // m_BobsMap, an instance of the map class

// We use another BobsMap object to keep a record of the best route each
// generation as an array of visited cells. This is only used for display purposes.
@property  (nonatomic, strong)  BobsMap  *bobsBrain;  // m_BobsBrain

- (id)initWithCrossoverRate:(double)crossRate
               mutationRate:(double)mutRate
                    popSize:(int)popSize
               chromoLength:(int)numBits
                 geneLength:(int)geneLen;

// private
- (void)mutate:(Genome *)genome;  // (vector<int> &vecBits);

- (void)crossoverMum:(Genome *)mum
                 dad:(Genome *)dad
               baby1:(Genome *)baby1
               baby2:(Genome *)baby2;

- (Genome *)rouletteWheelSelection;

//updates the genomes fitness with the new fitness scores and calculates
//the highest fitness and the fittest member of the population.
- (void)updateFitnessScores;

- (NSArray *)decode:(Genome *)genome;  // decodes a vector of bits into a vector of directions (ints)

// - (int)bitsToDirection:(int)num;  // not needed, converts a vector of bits into decimal. Used by Decode.

- (void)createStartPopulation;  // creates a start population of random bit strings

// public:

- (void)run;  // (HWND hwnd);

- (void)renderInView:(UIView *)view;  // (int cxClient, int cyClient, HDC surface);

- (void)epochLoop;

// accessor methods

- (BOOL)started;  // {return m_bBusy;}
- (void)stop;     // {m_bBusy = false;}

@end

NS_ASSUME_NONNULL_END
