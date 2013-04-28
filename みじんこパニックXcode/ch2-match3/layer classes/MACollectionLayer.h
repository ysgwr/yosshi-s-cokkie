//
//  CollectionLayer.h
//  ch2-match3
//
//  Created by 鈴木 宏昌 on 13/04/01.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MAMenuScene.h"
#import "MACollectionSprite.h"



@interface MACollectionLayer : CCLayer {
    //This is the window size returned from CCDirector
    //
    CGSize size;
    
    //This holds the spritesheet for the game
    //スプレッドシートを持つバッチノード
    CCSpriteBatchNode *matchsheet;
    
    //メニュー画面へ戻るボタンの宣言
    CCSprite *backButton; // simple sprite contro
    
    /*
    //array that holds all of the gems on the board
    //ボード上のすべてのgemを保持する配列
    NSMutableArray *gemsInPlay;
    
    //array that holds all scoring matched gems on the board
    //ボード上のスコアにマッチするgemを格納する配列
    NSMutableArray *gemMatches;
    
    //array that holds the gems currently in "touch" mode
    //現在タッチされてるgemを格納する配列
    NSMutableArray *gemsTouched;
    
    //BOOL to identify if there are gems still moving
    //現在動いているかどうかの変数
    BOOL gemsMoving;
     */
    
    //
    NSInteger totalGemsAvailable;
    
    
    //Spacing from the bottom edge to start the board
    //底を起点とした相対的な位置を表す数値(垂直的)
    float boardOffsetHeight;
    
    //amount of padding between gems
    //内側の余白(水平的)
    float padWidth;
    
    //amount of padding between gems
    //内側の余白(垂直的)
    float padHeight;
}

@end
