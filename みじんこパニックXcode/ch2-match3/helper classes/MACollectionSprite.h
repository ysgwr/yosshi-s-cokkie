//
//  MACollectionSprite.h
//  ch2-match3
//
//  Created by 鈴木 宏昌 on 13/04/01.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class MACollectionLayer;

typedef enum {
    kGemAnyType = 0,
    kGem1,
    kGem2,
    kGem3,
    kGem4,
    kGem5,
    kGem6,
    kGem7
} GemType;

typedef enum {
    kGemIdle = 100,
    kGemMoving,
    kGemScoring,
    kGemNew
} GemState;




@interface MACollectionSprite : CCSprite {
    NSInteger _rowNum; // Row number for this gem
    NSInteger _colNum; // Column number for this gem
    
    GemType _gemType; // The enum value of the gem
    
    GemState _gemState; // The current state of the gem
    
    MACollectionLayer *gameLayer; // The game layer
}
@property (nonatomic, assign) NSInteger rowNum;
@property (nonatomic, assign) NSInteger colNum;
@property (nonatomic, assign) GemType gemType;
@property (nonatomic, assign) GemState gemState;
@property (nonatomic, assign) MACollectionLayer *gameLayer;

-(BOOL) isGemSameAs:(MACollectionSprite*)otherGem;
-(BOOL) isGemInSameRow:(MACollectionSprite*)otherGem;
-(BOOL) isGemInSameColumn:(MACollectionSprite*)otherGem;
-(BOOL) isGemBeside:(MACollectionSprite*)otherGem;

-(void) highlightGem;
-(void) stopHighlightGem;

- (BOOL) containsTouchLocation:(CGPoint)pos;

@end
