//
//  MAResultLayer.m
//  ch2-match3
//
//  Created by 鈴木 宏昌 on 13/04/01.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "MAResultLayer.h"


@implementation MAResultLayer
    //初期化
-(id) init{
        if (self == [super init]){
            
            //タッチ検知の活動化
            self.isTouchEnabled = YES;
            
            //CCDirectorからウィンドウサイズを取得
            size = [[CCDirector sharedDirector] winSize];
            
            //バックグラウンドのイメージ追加
            CCSprite *bg = [CCSprite spriteWithFile:@"match3bg.png"];
            //中心にポジション
            [bg setPosition:ccp(size.width/2,size.height/2)];
            //最背面にCCSPrite bgを追加
            [self addChild:bg z:0];
            
            //スプライトのシートを指定
            matchsheet = [CCSpriteBatchNode batchNodeWithFile:@"match4sheet.png" capacity:54];
            
            //スプライトのスプレッドシートのロード
            [[CCSpriteFrameCache sharedSpriteFrameCache]
             addSpriteFramesWithFile:@"match4sheet.plist"];
            
             //バッチノードをレイヤーに加える
             [self addChild:matchsheet z:1];
             
             //右下にバックのボタンを配置する
             backButton = [CCSprite spriteWithSpriteFrameName:@"backbutton.png"];
             //アンカーポイントを設置
             //ccpはccpはcocos2dの便利マクロらしく、CGPointをMakeしてくれる
             [backButton setAnchorPoint:ccp(0,0)];
             [backButton setScale:0.7];
             [backButton setPosition:ccp(10,10)];
             [matchsheet addChild:backButton];
             
    }
    return self;
}

//メモリの解放
-(void) dealloc {
    self.isTouchEnabled = NO;
    [super dealloc];
}
//viewWillApearみたいなもの。レイヤーの表示時に呼ばれる。
-(void)onEnter
{
    [[[CCDirector sharedDirector] touchDispatcher]
     addTargetedDelegate:self priority:0
     swallowsTouches:YES];
    
    [super onEnter];
}

//viewWillDisapearみたいなのも。レイヤーの非表示時に呼ばれる
-(void)onExit
{
    [[[CCDirector sharedDirector] touchDispatcher]
     removeDelegate:self];
    
    [super onExit];
}


//タッチを検知して、どのボタンが押されたかを処理する
-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint convLoc = [[CCDirector sharedDirector]convertToGL:location];
    
    NSLog(@"convLoc:%f", convLoc.x);
    // If the back button was pressed, we exit
    //「menuへ戻る」を選択したら
    if (CGRectContainsPoint([backButton boundingBox],
                            convLoc)) {
        [[CCDirector sharedDirector]
         replaceScene:[MAMenuScene node]];
        return YES;
    }
    
    // If we failed to find any good touch, return
    return NO;
}


//タッチが動かされているときの処理
-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    // Swipes are handled here.
    //[self touchHelper:touch withEvent:event];
}


//タッチが終わったときの処理
-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    // Taps are handled here.
    //[self touchHelper:touch withEvent:event];
}





@end
