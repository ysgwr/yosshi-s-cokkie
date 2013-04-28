//
//  MAPlayfieldLayer.h
//  ch2-match3
//  Creating Games with cocos2d for iPhone 2
//
//  Copyright 2012 Paul Nygard
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MAMenuScene.h"
#import "MAResultScene.h"
#import "MAPlayfieldSprite.h"
#import "SimpleAudioEngine.h"



enum direction {
    UP =1 ,
    DOWN =2,
    RIGHT=3,
    LEFT=4
};

//MAPlayfieldLayerの定義
@interface MAPlayfieldLayer : CCLayer {
    CGSize size; // This is the window size returned from CCDirector
    
    CCSpriteBatchNode *matchsheet; // This holds the spritesheet for the game
    
    //メニュー画面へ戻るボタンの宣言
    CCSprite *backButton; // simple sprite control to leave the scene
    
    //array that holds all of the gems on the board
    //ボート上のすべてのgemを保持する可変配列
    CCArray *gemsInPlay;
    
    //array that holds all scoring matched gems on the board
    //スコアリングにマッチしたすべてのgemを保持する可変配列
    
    
    CCArray *gemMatches;
    
    //array that holds the gems currently in "touch" mode
    //現在「タッチモード」になっているgemを保持する可変配列
    CCArray *gemsTouched;
    
    CCArray *values;
    
    //Number of gem columns on the board
    //ボード上の行の数値
    NSInteger boardColumns;
    
    //Number of gem rows on the board
    //ボード上の列の数値
    NSInteger boardRows;
    
    //Spacing from the left edge to start the board
    //オフセットとは、基準となるある点からの相対的な位置のことである
    //左端を起点とした相対的な位置を表す数値(水平的)
    float boardOffsetWidth;
    
    //Spacing from the bottom edge to start the board
    //底を起点とした相対的な位置を表す数値(垂直的)
    float boardOffsetHeight;
    
    //amount of padding between gems
    //内側の余白(水平的)
    float padWidth;
    
    //amount of padding between gems
    //内側の余白(垂直的)
    float padHeight;
    
    //total number of unique gems
    //ユニークなgemの総量
    NSInteger totalGemsAvailable;
    
    //Dimensions of an individual gem
    //gemのサイズ
    CGSize gemSize;
    
    //BOOL we set to let us know we need to check for matches
    //
    BOOL checkMatches;
    
    //BOOL to identify if there are gems still moving
    BOOL gemsMoving;
    
    //Projected number of moves remaining/available
    NSInteger movesRemaining;
    
    //Current score
    //現在のスコア値
    NSInteger playerScore;
    
    //Label to display he current score
    //文字列を扱うテクスチャの変数
    CCLabelTTF *scoreLabel;
    
    //gameplay timer display
    CCProgressTimer *timerDisplay;
    
    //actual value of time remaining
    float currentTimerValue;
    
    //initial value of the timer - we count down
    //タイマーの数値
    float startingTimerValue;
    
    //flag for game over condition
    //ゲームオーバーかどうかのフラグ
    BOOL isGameOver;
    
    int currentlyMoving;
    int directionMoving;
    CGPoint lastLocation;
    CGPoint startLocation;
}

@property NSInteger playerScore;

@end
