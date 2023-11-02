//
//  BobsMap.m
//  PathfinderPhone
//
//  Created by Igor Delovski on 22/10/2023.
//  Copyright © 2023 Igor Delovski. All rights reserved.
//

#import  "BobsMap.h"

#import  "BobsGenome.h"

const int  staticMap[kMapHeight][kMapWidth] = {
   /* 1*/  { 1, 1, 1, 1, 1, 1, 1, 8, 1, 1, 1, 1 },
   /* 2*/  { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1 },
   /* 3*/  { 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 0, 1 },
   /* 4*/  { 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1 },
   /* 5*/  { 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1 },
   /* 6*/  { 1, 0, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1 },
   /* 7*/  { 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 },
   /* 8*/  { 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 0, 1 },
   /* 9*/  { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1 },
   /*10*/  { 1, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 1 },
   /* 1*/  { 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1 },
   /* 2*/  { 1, 0, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1 },
   /* 3*/  { 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1 },
   /* 4*/  { 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1 },
   /* 5*/  { 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1 },
   /* 6*/  { 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1 },
   /* 7*/  { 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1 },
   /* 8*/  { 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1 },
   /* 9*/  { 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1 },
   /*20*/  { 1, 1, 1, 1, 5, 1, 1, 1, 1, 1, 1, 1 }
};


@implementation BobsMap

- (id)init
{
   if (self = [super init])  {
      BobsMapData  data;
      
      data.mapHeight = kMapHeight;
      data.mapWidth  = kMapWidth;
      
      data.idxStartX = 4;
      data.idxStartY = 19;
      
      data.idxEndX = 7;
      data.idxEndY = 0;
      
      BlockMove (staticMap, data.mapRoom, sizeof(int) * kMapWidth * kMapHeight);
      
      memset (&data.mapMemory, '\0', sizeof(int) * kMapWidth * kMapHeight);

      self.mapData = data;
   }
   
   return (self);
}

-(void)renderInView:(UIView *)view;  // CBobsMap::Render (const int cxClient, const int cyClient, HDC surface)
{
   BobsMapData  mapData = self.mapData;
   
   CGFloat  xBorder = 16;
   CGFloat  yBorder = 48;
   CGRect   viewFrame = view.bounds;
   
   CGFloat  blockSizeX = (viewFrame.size.width - 2*xBorder)/mapData.mapWidth;
   CGFloat  blockSizeY = (viewFrame.size.height - 2*yBorder)/mapData.mapHeight;
   
#ifdef _NIJE_
   HBRUSH   blackBrush, redBrush, oldBrush;
   HPEN     nullPen, oldPen;
   
   nullPen = (HPEN)GetStockObject (NULL_PEN);   //grab a null pen so we can see the outlines of the cells
   
   blackBrush = (HBRUSH)GetStockObject (BLACK_BRUSH);   //grab a brush to fill our cells with
   
   redBrush = CreateSolidBrush (RGB(255,0,0));   //create a brush for the exit/entrance points
   
   oldBrush = (HBRUSH)SelectObject (surface, blackBrush);   //select them into the device conext
   oldPen   = (HPEN)SelectObject (surface, nullPen);
#endif
   
   for (int y=0; y<mapData.mapHeight; y++)  {
      /*NSLog (@"%d %d %d %d %d %d %d %d %d %d ",
             mapData.mapRoom[y][0],
             mapData.mapRoom[y][1],
             mapData.mapRoom[y][2],
             mapData.mapRoom[y][3],
             mapData.mapRoom[y][4],
             mapData.mapRoom[y][5],
             mapData.mapRoom[y][6],
             mapData.mapRoom[y][7],
             mapData.mapRoom[y][8],
             mapData.mapRoom[y][9]
             );*/
      for (int x=0; x<mapData.mapWidth; x++)  {
         
         //calculate the corners of each cell
         CGFloat  left  = xBorder + (blockSizeX * x);
         CGFloat  right = left + blockSizeX;
         
         CGFloat  top    = yBorder + (blockSizeY * y);
         CGFloat  bottom = top + blockSizeY;
         
         CGRect         boxFrame = CGRectInset (CGRectMake (left, top/*-16*/, right-left, bottom-top), .5, .5);
         UIBezierPath  *rectPath = [UIBezierPath bezierPathWithRect:boxFrame];

         if (mapData.mapRoom[y][x] == 1)  {         //draw black rectangle if this is a wall
            // SelectObject (surface, blackBrush);
            [[UIColor darkGrayColor] setFill];
         }
         else  if (mapData.mapRoom[y][x] == 5)  {         //draw red for entrance
            // SelectObject (surface, redBrush);
            [[UIColor redColor] setFill];
         }
         else  if (mapData.mapRoom[y][x] == 8)  {         //draw green for exit
            // SelectObject (surface, redBrush);
            [[UIColor greenColor] setFill];
         }
         else
            continue;
         [rectPath fill];  // Rectangle (surface, left, top, right, bottom);            //draw the cell
      }
   }
   
   // SelectObject (surface, oldBrush);   //restore the original brush
   // SelectObject (surface, oldPen);   //and pen
}

//-------------------------------MemoryRender ------------------------
//
//   //draws whatever path may be stored in the memory
//--------------------------------------------------------------------

- (void)memoryRenderInView:(UIView *)view;  // CBobsMap::MemoryRender (const int cxClient, const int cyClient, HDC surface)
{
   BobsMapData  mapData = self.mapData;
   
   CGFloat  xBorder = 16;
   CGFloat  yBorder = 48;
   CGRect   viewFrame = view.bounds;
   
   CGFloat  blockSizeX = (viewFrame.size.width - 2*xBorder)/mapData.mapWidth;
   CGFloat  blockSizeY = (viewFrame.size.height - 2*yBorder)/mapData.mapHeight;

#ifdef _NIJE_   
   HBRUSH  greyBrush, oldBrush;
   HPEN    nullPen, oldPen;
   
   greyBrush = (HBRUSH)GetStockObject (LTGRAY_BRUSH);   //grab a brush to fill our cells with
   nullPen   = (HPEN)GetStockObject (NULL_PEN);         //grab a pen
   
   oldBrush = (HBRUSH)SelectObject (surface, greyBrush);   //select them into the device conext
   oldPen   = (HPEN)SelectObject (surface, nullPen);
#endif
   
   [[UIColor grayColor] setFill];
   
   for (int y=0; y<mapData.mapHeight; y++)  {
      /*NSLog (@"%d %d %d %d %d %d %d %d %d %d ",
             mapData.mapMemory[y][0],
             mapData.mapMemory[y][1],
             mapData.mapMemory[y][2],
             mapData.mapMemory[y][3],
             mapData.mapMemory[y][4],
             mapData.mapMemory[y][5],
             mapData.mapMemory[y][6],
             mapData.mapMemory[y][7],
             mapData.mapMemory[y][8],
             mapData.mapMemory[y][9]
             );*/
      for (int x=0; x<mapData.mapWidth; x++)  {
         //calculate the corners of each cell
         CGFloat  left  = xBorder + (blockSizeX * x);
         CGFloat  right = left + blockSizeX;
         
         CGFloat  top    = yBorder + (blockSizeY * y);
         CGFloat  bottom = top + blockSizeY;
         
         CGRect         boxFrame = CGRectInset (CGRectMake (left, top/*-16*/, right-left, bottom-top), .5, .5);
         UIBezierPath  *rectPath = [UIBezierPath bezierPathWithRect:boxFrame];

         if (mapData.mapMemory[y][x] == 1)         // draw gray rectangle if this is a bob's path
            [rectPath fill];  // Rectangle (surface, left, top, right, bottom);
      }
   }
   
   // SelectObject (surface, oldBrush);   //restore the original brush
   // SelectObject (surface, oldPen);     //and pen
}

//---------------------------- TestRoute ---------------------------
//
//   given a decoded vector of directions and a map object representing
//   Bob's memory, this function moves Bob through the maze as far as 
//   he can go updating his memory as he moves.
//-------------------------------------------------------------------

- (double)testRoute:(NSArray *)directionsArray mapData:(BobsMapData *)memory;  //  CBobsMap::TestRoute (const vector<int> &vecPath, CBobsMap &Bobs)
{
   BobsMapData  mapData = self.mapData;

   int  posX = mapData.idxStartX;
   int  posY = mapData.idxStartY;
   
   for (int dir=0; dir<directionsArray.count; dir++)  {
      // int  nextDir = vecPath[dir];
      NSNumber  *vecStep = [directionsArray objectAtIndex:dir];
      int        direction = [vecStep intValue]; 
      
      switch (direction)  {
         case  kBobMoveNorth: // 0
            
            if ( ((posY-1) < 0 ) || (mapData.mapRoom[posY-1][posX] == 1) )         //check within bounds and that we can move
               break;
            else
               posY -= 1;
            break;
            
         case  kBobMoveSouth: // 1
            
            if ( ((posY+1) >= mapData.mapHeight) || (mapData.mapRoom[posY+1][posX] == 1) )         //check within bounds and that we can move
               break;
            else
               posY += 1;
            break;
            
         case kBobMoveEast: // 2
            
            if ( ((posX+1) >= mapData.mapWidth ) || (mapData.mapRoom[posY][posX+1] == 1) )         //check within bounds and that we can move
               break;
            else
               posX += 1;
            break;
            
         case kBobMoveWest: // 3
            if ( ((posX-1) < 0 ) || (mapData.mapRoom[posY][posX-1] == 1) )         //check within bounds and that we can move
               break;
            else
               posX -= 1;
            break;
            
      }//end switch
      
      memory->mapMemory[posY][posX] = 1;      //mark the route in the memory array
   }//next direction
   
   //now we know the finish point of Bobs journey, let's assign
   //a fitness score which is proportional to his distance from
   //the exit
   
   int  diffX = abs (posX - mapData.idxEndX);
   int  diffY = abs (posY - mapData.idxEndY);
   
   return (1./(double)(diffX + diffY + 1));   //we add the one to ensure we never divide by zero.
}

//--------------------- ResetMemory --------------------------
//
//   resets the memory map to zeros
//------------------------------------------------------------
- (void)resetMemory;  // CBobsMap::ResetMemory ()
{
   for (int y=0; y<self.mapData.mapHeight; ++y)  {
      for (int x=0; x<self.mapData.mapWidth; ++x)
         self.mapData.mapMemory[y][x] = 0;
   }
}

@end
