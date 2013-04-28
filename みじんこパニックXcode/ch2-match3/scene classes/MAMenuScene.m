//
//  MAMenuScene.m
//  ch2-match3
//  Creating Games with cocos2d for iPhone 2
//
//  Copyright 2012 Paul Nygard
//

#import "MAMenuScene.h"
#import "MAMenuLayer.h"

@implementation MAMenuScene


//Sceneクラスのインスタンスオブジェクトを返す
+(id)scene {
    return( [ [ [ self alloc ] init ] autorelease ] );
}


//初期化
-(id) init
{
	if( (self=[super init])) {
        //layerのインスタンスを作成する
        MAMenuLayer *layer = [MAMenuLayer node];
        //layerを画面に追加
        [self addChild: layer];
	}
	return self;
}

@end
