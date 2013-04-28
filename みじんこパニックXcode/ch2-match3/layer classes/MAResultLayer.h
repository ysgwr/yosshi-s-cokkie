//
//  MAResultLayer.h
//  ch2-match3
//
//  Created by 鈴木 宏昌 on 13/04/01.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MAMenuScene.h"
#import "MACollectionSprite.h"

@interface MAResultLayer : CCLayer {
    //This is the window size returned from CCDirector
    //
    CGSize size;
    
    //This holds the spritesheet for the game
    //スプレッドシートを持つバッチノード
    CCSpriteBatchNode *matchsheet;
    
    //メニュー画面へ戻るボタンの宣言
    CCSprite *backButton; // simple sprite contro
    
    //amount of padding between gems
    //内側の余白(水平的)
    float padWidth;
    
    //amount of padding between gems
    //内側の余白(垂直的)
    float padHeight;
    
}

@end
