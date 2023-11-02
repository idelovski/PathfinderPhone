//
//  BobsGenome.m
//  PathfinderPhone
//
//  Created by Igor Delovski on 24/10/2023.
//  Copyright © 2023 Igor Delovski. All rights reserved.
//

#import  "BobsGenome.h"

@implementation BobsGenAlgo

- (id)initWithCrossoverRate:(double)crossRate
               mutationRate:(double)mutRate
                    popSize:(int)popSize
               chromoLength:(int)numBits
                 geneLength:(int)geneLen;
{
   if (self = [super init])  {
      self.genomesArray = [NSMutableArray arrayWithCapacity:popSize];
      
      self.populationSize = popSize;
      self.chromoLength = numBits;
      self.crossoverRate = crossRate;
      self.mutationRate = mutRate;
      self.geneLength = geneLen;
      
      self.generation = 0;
      
      self.bestFitnessScore = self.totalFitnessScore = 0.;
      
      self.bobsMap = [[BobsMap alloc] init];
      self.bobsBrain = [[BobsMap alloc] init];

   }
   
   return (self);
}

//--------------------------RouletteWheelSelection-----------------
//
//   selects a member of the population by using roulette wheel 
//   selection as described in the text.
//------------------------------------------------------------------
- (Genome *)rouletteWheelSelection;
{
   double  fSlice = [Genome randomFloat] * self.totalFitnessScore;
   double  cfTotal   = 0.0;
   
   int  selectedGenome = 0;
   
   for (int i=0; i<self.populationSize; i++)  {
      Genome  *oneGenome = [self.genomesArray objectAtIndex:i];

      cfTotal += oneGenome.fitness;  // m_vecGenomes[i].dFitness;
      
      if (cfTotal > fSlice)  {
         selectedGenome = i;
         break;
      }
   }
   
   return ([self.genomesArray objectAtIndex:selectedGenome]);
}

//----------------------------Mutate---------------------------------
//   iterates through each genome flipping the bits acording to the
//   mutation rate
//--------------------------------------------------------------------
- (void)mutate:(Genome *)genome;  // void CgaBob::Mutate(vector<int> &vecBits)
{
   Vector  vector = genome.vector;
   
   for (int curBit=0; curBit<vector.length; curBit++)  {
      //do we flip this bit?
      if ([Genome randomFloat] < self.mutationRate)
         vector.vec[curBit] = !vector.vec[curBit];  //flip the bit
   }
}

//----------------------------Crossover--------------------------------
//   Takes 2 parent vectors, selects a midpoint and then swaps the ends
//   of each genome creating 2 new genomes which are stored in baby1 and
//   baby2.
//---------------------------------------------------------------------
- (void)crossoverMum:(Genome *)mum
                 dad:(Genome *)dad
               baby1:(Genome *)baby1
               baby2:(Genome *)baby2;
{
   int  i;
   
   // just return parents as offspring dependent on the rate or if parents are the same
   if (([Genome randomFloat] > self.crossoverRate) || (mum == dad))  {
      for (i=0; i<self.chromoLength; i++)  {   // swap the bits
         baby1.vector.vec[i] = mum.vector.vec[i];
         baby2.vector.vec[i] = dad.vector.vec[i];
      }
      return;
   }
   
   //determine a crossover point
   int  cp = [Genome randomIntFrom:0 to:self.chromoLength - 1];  // RandInt(0, m_iChromoLength - 1);

   for (i=0; i<cp; i++)  {   // swap the bits
      baby1.vector.vec[i] = mum.vector.vec[i];
      baby2.vector.vec[i] = dad.vector.vec[i];
   }

   for (i=cp; i<self.chromoLength; i++)  {
      baby1.vector.vec[i] = dad.vector.vec[i];
      baby2.vector.vec[i] = mum.vector.vec[i];
   }
}
//-----------------------------------Run----------------------------------
//
//   This is the function that starts everything. It is mainly another 
//   windows message pump using PeekMessage instead of GetMessage so we
//   can easily and dynamically make updates to the window while the GA is 
//   running. Basically, if there is no msg to be processed another Epoch
//   is performed.
//------------------------------------------------------------------------
- (void)run;  // void CgaBob::Run(HWND hwnd)
{
   [self createStartPopulation];   // The first thing we have to do is create a random population of genomes
   
   self.busy = YES;
}
//----------------------CreateStartPopulation---------------------------
//
//-----------------------------------------------------------------------
- (void)createStartPopulation;  // void CgaBob::CreateStartPopulation()
{
   [self.genomesArray removeAllObjects];   // clear existing population
   
   for (int i=0; i<self.populationSize; i++)  {
      Genome  *aGenome = [[Genome alloc] initWithGeneLength:self.chromoLength];
      
      [self.genomesArray addObject:aGenome];  //  m_vecGenomes.push_back(SGenome(m_iChromoLength));
   }

   // reset all variables
   self.generation    = 0;
   self.fittestGenome = 0;
   self.bestFitnessScore  = 0.;
   self.totalFitnessScore = 0.;
}
//--------------------------------Epoch---------------------------------
//
//   This is the workhorse of the GA. It first updates the fitness
//   scores of the population then creates a new population of
//   genomes using the Selection, Croosover and Mutation operators
//   we have discussed
//----------------------------------------------------------------------
- (void)epochLoop;  // void CgaBob::Epoch()
{
   int              newBabiesCnt = 0;   //Now to create a new population
   NSMutableArray  *babyGenomes = [NSMutableArray arrayWithCapacity:self.populationSize];   // create some storage for the baby genomes 
   
   [self updateFitnessScores];

   while (newBabiesCnt < self.populationSize)  {
      Genome  *baby1 = [[Genome alloc] initWithGeneLength:self.chromoLength];
      Genome  *baby2 = [[Genome alloc] initWithGeneLength:self.chromoLength];
      //select 2 parents
      Genome  *mum = [self rouletteWheelSelection];  // RouletteWheelSelection();
      Genome  *dad = [self rouletteWheelSelection];  // RouletteWheelSelection();

      [self crossoverMum:mum dad:dad baby1:baby1 baby2:baby2]; // operator - crossover
      // Crossover (mum.vecBits, dad.vecBits, baby1.vecBits, baby2.vecBits);

      //operator - mutate
      [self mutate:baby1];
      [self mutate:baby2];

      [babyGenomes addObject:baby1];  // add to new population
      [babyGenomes addObject:baby2];

      newBabiesCnt += 2;
   }

   self.genomesArray = babyGenomes;   // copy babies back into starter population

   self.generation++;   // increment the generation counter
}

//---------------------------UpdateFitnessScores------------------------
//   updates the genomes fitness with the new fitness scores and calculates
//   the highest fitness and the fittest member of the population.
//   Also sets m_pFittestGenome to point to the fittest. If a solution
//   has been found (fitness == 1 in this example) then the run is halted
//   by setting m_bBusy to false
//-----------------------------------------------------------------------
- (void)updateFitnessScores;  //  void CgaBob::UpdateFitnessScores()
{
   self.fittestGenome     = 0;
   self.bestFitnessScore  = 0;
   self.totalFitnessScore = 0;

   BobsMap  *tempMap = [[BobsMap alloc] init];
   
   BobsMapData  mapData = tempMap.mapData;
    
   //update the fitness scores and keep a check on fittest so far
   for (int i=0; i<self.populationSize && self.busy; ++i)  {
      Genome   *aGenome = [self.genomesArray objectAtIndex:i];
      NSArray  *directionsArray = [self decode:aGenome];      // decode each genomes chromosome into a vector of directions
      
      // OK, this won't work as I don't understand what is really tested in there
      aGenome.fitness = [self.bobsMap testRoute:directionsArray mapData:&mapData];  // get it's fitness score

      self.totalFitnessScore += aGenome.fitness;      // update total

      if (aGenome.fitness > self.bestFitnessScore)  {      // if this is the fittest genome found so far, store results

         self.bestFitnessScore = aGenome.fitness;

         self.fittestGenome = i;

         self.bobsBrain.mapData = mapData;

         if (aGenome.fitness == 1)   // Has Bob found the exit?
            self.busy = NO;  // is so, stop the run
      }

      [tempMap resetMemory];
   
   }//next genome
}

//---------------------------Decode-------------------------------------
//
//   decodes a vector of bits into a vector of directions (ints)
//
//   0=North, 1=South, 2=East, 3=West
//-----------------------------------------------------------------------
- (NSArray *)decode:(Genome *)genome;  //  vector<int> CgaBob::Decode(const vector<int> &bits)
{
   Vector           vector = genome.vector;  // each int acts as a bit and we need two bits for full information
   NSMutableArray  *directions = [NSMutableArray array];  //  vector<int>   directions;
   
   //step through the chromosome a gene at a time
   for (int gix=0; gix < vector.length; gix += self.geneLength)  {
      int  gene = 0;  // vector<int> ThisGene;  // get the gene at this position
      
      for (int bit = 0; bit < self.geneLength; bit++)  {
         gene *= 2;
         gene += vector.vec[gix+bit];  // ThisGene.push_back(bits[gene+bit]);
      }
      
      [directions addObject:[NSNumber numberWithInt:gene]];  //  directions.push_back(BinToInt(ThisGene)); - convert to decimal and add to list of directions
   }
   
   return (directions);
}

//------------------------- Render -------------------------------
//
//   given a surface to render to this function renders the map
//   and the best path if relevant. cxClient/cyClient are the 
//   dimensions of the client window.
//----------------------------------------------------------------
- (void)renderInView:(UIView *)view;  // void  CgaBob::Render (int cxClient, int cyClient, HDC surface)
{
   [self.bobsBrain memoryRenderInView:view];  // m_BobsBrain.MemoryRender (cxClient, cyClient, surface);   //render the best route
   
   [self.bobsMap renderInView:view];  // (cxClient, cyClient, surface);  //render the map
   
   NSLog (@"renderInView:");
#ifdef _NIJE_
   // Create labels in mainView
   string  s = "Generation: " + itos (m_iGeneration);   //Render additional information
   
   TextOut (surface, 5, 0, s.c_str(), s.size());
   
   if (!m_bBusy)  {
      string  start = "Press Return to start a new run";
      
      TextOut (surface, cxClient/2 - (start.size() * 3), cyClient - 20, start.c_str(), start.size());
   }
   else  {
      string  start = "Space to stop";
      
      TextOut (surface, cxClient/2 - (start.size() * 3), cyClient - 20, start.c_str(), start.size());
   }
#endif
}

- (BOOL)started;  // {return m_bBusy;}
{
   return (self.busy);
}
- (void)stop;     // {m_bBusy = false;}
{
   self.busy = YES;
}

@end

@implementation Genome

- (id)initWithGeneLength:(int)geneLen;
{
   if (self = [super init])  {
      Vector  vector;
      
      vector.vec = malloc (sizeof(int) * geneLen);
      vector.length = geneLen;
      
      self.vector = vector;
      
      [self clear];
   }
        
   return (self);
}

- (void)clear;
{
   for (int i=0; i<self.vector.length; i++)
      self.vector.vec[i] = [Genome randomIntFrom:0 to:1];
}

- (void)dealloc
{
   if (_vector.vec)  {
      free (_vector.vec);
      _vector.vec = NULL;
   }
}

+ (int)randomIntFrom:(int)from to:(int)to
{
   int  value = from + arc4random_uniform ((to-from) + 1);
   
   return (value);
}

+ (double)randomFloat;
{
   int  value = [self randomIntFrom:0 to:100000];  // or double val = ((double)arc4random() / UINT32_MAX);
   
   return ((double)value / 100000.);
}

@end
