//
//  MAMenuLayer.m
//  ch2-match3
//  Creating Games with cocos2d for iPhone 2
//
//  Copyright 2012 Paul Nygard
//

#import "MAMenuLayer.h"

@implementation MAMenuLayer


//初期化して
-(id) init
{
    if( (self=[super init])) {
        
        CGSize wins = [[CCDirector sharedDirector] winSize];
        
        // Build a basic title
        //題名をつける
        //文字列とフォントの指定
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Match 3" fontName:@"Marker Felt" fontSize:64];
        //文字色の指定
        [label setColor:ccWHITE];
        //ラベルの配置を画面の中央に指定する
		label.position =  ccp( wins.width /2 , wins.height/2 );
        //定義したラベルを画面に追加する
		[self addChild: label];
        
        
        // Build the start menu
        //PlayFieldLayerへのスタートボタンを用意
        //文字列とフォントの指定
        CCLabelTTF *startGameLbl = [CCLabelTTF labelWithString:@"Start Game" fontName:@"Marker Felt" fontSize:22];
        
        //遷移メソッドのデリゲート
        CCMenuItemLabel *startGameItem = [CCMenuItemLabel itemWithLabel:startGameLbl target:self selector:@selector(startGame)];
        CCMenu *startMenu = [CCMenu menuWithItems:startGameItem, nil];
        
        //ラベルの配置を指定する
        [startMenu setPosition:ccp(wins.width/2, wins.height/4)];
        
        //定義したラベルを画面に追加する
        [self addChild:startMenu];
        
        
        // Build the collection menu
        //collectionLayerへのボタンを用意
        //文字列とフォントの指定
        //CCLabelTTF *startGameLbl = [CCLabelTTF labelWithString:@"Start Game" fontName:@"Marker Felt" fontSize:22];
        CCLabelTTF *collectionLbl = [CCLabelTTF labelWithString:@"Collection" fontName:@"Marker Felt" fontSize:22];
        
        //遷移メソッドのデリゲート
        //CCMenuItemLabel *startGameItem = [CCMenuItemLabel itemWithLabel:startGameLbl target:self selector:@selector(startGame)];
        
        CCMenuItemLabel *collectionItem = [CCMenuItemLabel itemWithLabel:collectionLbl target:self selector:@selector(collectMijinko)];
        
        //CCMenu *startMenu = [CCMenu menuWithItems:startGameItem, nil];
        CCMenu *collectionMenu = [CCMenu menuWithItems:collectionItem, nil];
        
        //ラベルの配置を指定する
        [collectionMenu setPosition:ccp(wins.width/2, wins.height/6)];
        
        //定義したラベルを画面に追加する
        [self addChild:collectionMenu];
	}
    return self;
}

//プレイ画面への遷移
-(void) startGame {
    // Start the game, called by the menu item
    [[CCDirector sharedDirector] replaceScene:[MAPlayfieldScene scene]];
}

//コレクション画面への遷移
-(void) collectMijinko {
    [[CCDirector sharedDirector] replaceScene:[MACollectionScene scene]];
}

@end
