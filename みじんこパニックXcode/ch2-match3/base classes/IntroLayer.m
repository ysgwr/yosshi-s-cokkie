//
//  IntroLayer.m
//  ch2-match3
//  Creating Games with cocos2d for iPhone 2
//
//  Copyright 2012 Paul Nygard
//

// Import the interfaces
#import "IntroLayer.h"
#import "MAMenuScene.h"

#pragma mark - IntroLayer

// HelloWorldLayer implementation
@implementation IntroLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
//
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
    //'scene'はオートリリースされる
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
    //'layer'はオートリリースされる
	IntroLayer *layer = [IntroLayer node];
	
	// add layer as a child to scene
    //sceneの表示クラスのインスタンスlayerを追加する
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// viewWillApearみたいなもの。レイヤーの表示時に呼ばれる
-(void) onEnter
{
	[super onEnter];

	// ask director for the window size
    //ディレクターにウインドウのサイズをきく
	CGSize size = [[CCDirector sharedDirector] winSize];

    //起動時表示されるロゴをSpriteとして定義
	CCSprite *background;
	
    //iPhoneで動いていた場合
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
        //起動時のロゴとして表示される画像の指定
		background = [CCSprite spriteWithFile:@"Default.png"];
		background.rotation = 90;
        
    //iPadで動いていた場合
	} else {
        //起動時のロゴとして表示される画像の指定
		background = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
	}
	background.position = ccp(size.width/2, size.height/2);

	// add the label as a child to this Layer
    //起動時のロゴとして表示される画像を画面に表示するようにする
	[self addChild: background];
	
    
	// In one second transition to the new scene
    //次のSceneまでの間隔を調整する
	[self scheduleOnce:@selector(makeTransition:) delay:1];
    
}

//MAMenuSceneへ画面遷移する
-(void) makeTransition:(ccTime)dt
{
    //画面遷移する時のアニメーション効果を指定
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MAMenuScene scene] withColor:ccWHITE]];
}
@end
