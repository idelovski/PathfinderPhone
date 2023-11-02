//
//  BobsMap.h
//  PathfinderPhone
//
//  Created by Igor Delovski on 22/10/2023.
//  Copyright © 2023 Igor Delovski. All rights reserved.
//

#import  <UIKit/UIKit.h>

#define  kMapHeight  20
#define  kMapWidth   12

#define  BlockMove(s,d,l)  memmove(d,s,l)
            
NS_ASSUME_NONNULL_BEGIN

typedef  struct  _BobsMapData
{
   int  mapRoom[kMapHeight][kMapWidth];
   int  mapWidth;
   int  mapHeight;
   
   //index into the array which is the start point
   int  idxStartX;
   int  idxStartY;
   
   //and the finish point
   int   idxEndX;
   int   idxEndY;

   int   mapMemory[kMapHeight][kMapWidth];
} BobsMapData;

@interface BobsMap : NSObject

@property  (nonatomic, assign)  BobsMapData  mapData;

// Takes a string of directions and see's how far Bob can get.
// Returns a fitness score proportional to the distance reached from the exit.
- (double)testRoute:(NSArray *)directionsArray mapData:(BobsMapData *)memory;

// Given a surface to draw on this function uses the windows GDI to display the map.
- (void)renderInView:(UIView *)view;  // (const int cxClient, const int cyClient, HDC surface);

// Draws whatever path may be stored in the memory
- (void)memoryRenderInView:(UIView *)view;  //  (const int cxClient, const int cyClient, HDC surface);

- (void)resetMemory;

@end

NS_ASSUME_NONNULL_END
