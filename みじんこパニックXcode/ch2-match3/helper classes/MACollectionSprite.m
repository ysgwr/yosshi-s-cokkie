//
//  MACollectionSprite.m
//  ch2-match3
//
//  Created by 鈴木 宏昌 on 13/04/01.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "MACollectionSprite.h"


@implementation MACollectionSprite
@synthesize rowNum = _rowNum;
@synthesize colNum = _colNum;
@synthesize gemType = _gemType;
@synthesize gemState = _gemState;

@synthesize gameLayer;

//他のgemと同じであるかのチェック
-(BOOL) isGemSameAs:(MACollectionSprite*)otherGem {
    // Is the gem the same type as the other Gem?
    return (self.gemType == otherGem.gemType);
}

//他のgemと同じ列であるかのチェック
-(BOOL) isGemInSameRow:(MACollectionSprite*)otherGem {
    // Is the gem in the same row as the other Gem?
    return (self.rowNum == otherGem.rowNum);
}

//他のgemと同じ行であるかのチェック
-(BOOL) isGemInSameColumn:(MACollectionSprite*)otherGem {
    // Is the gem in the same column as the other gem?
    return (self.colNum == otherGem.colNum);
}

//他のgemが隣同士であるかのチェック
-(BOOL) isGemBeside:(MACollectionSprite*)otherGem {
    // If the row is the same, and the other gem is
    // +/- 1 column, they are neighbors
    if ([self isGemInSameRow:otherGem] &&
        ((self.colNum == otherGem.colNum - 1) ||
         (self.colNum == otherGem.colNum + 1))
        ) {
        return YES;
    }
    // If the column is the same, and the other gem is
    // +/- 1 row, they are neighbors
    else if ([self isGemInSameColumn:otherGem] &&
             ((self.rowNum == otherGem.rowNum - 1) ||
              (self.rowNum == otherGem.rowNum + 1))
             ) {
        return YES;
    } else {
        return NO;
    }
}

/*
//タッチされたとき、ぐらぐらするアニメーションの処理
#pragma mark Animate the touch
-(void) highlightGem {
    // Build a simple repeating "wobbly" animation
    CCMoveBy *moveUp = [CCMoveBy actionWithDuration:0.1
                                           position:ccp(0,3)];
    CCMoveBy *moveDown = [CCMoveBy actionWithDuration:0.1
                                             position:ccp(0,-3)];
    CCSequence *moveAround = [CCSequence actions:moveUp,
                              moveDown, nil];
    CCRepeatForever *gemHop = [CCRepeatForever
                               actionWithAction:moveAround];
    
    [self runAction:gemHop];
}


//タッチされたとき、ぐらぐらするアニメーションをストップする処理
-(void) stopHighlightGem {
    // Stop all actions (the wobbly) on the gem
    [self stopAllActions];
    
    // We call to the gameLayer itself to make sure we
    // haven't left the gem a little off-base
    // (from the highlightGem movements)
    [gameLayer performSelector:@selector(resetGemPosition:)
                    withObject:self];
}
*/

#pragma mark Touch Detection
//タッチしたときの場所の座標
- (BOOL)containsTouchLocation:(CGPoint)pos
{
    // Was this gem touched?
	return CGRectContainsPoint(self.boundingBox, pos);
}

-(void) dealloc {
    [self setGameLayer:nil];
    
    [super dealloc];
}


@end
