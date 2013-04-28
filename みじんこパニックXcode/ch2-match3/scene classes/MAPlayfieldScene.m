//
//  MAPlayfieldScene.m
//  ch2-match3
//  Creating Games with cocos2d for iPhone 2
//
//  Copyright 2012 Paul Nygard
//

#import "MAPlayfieldScene.h"
#import "MAPlayfieldLayer.h"

@implementation MAPlayfieldScene

//Sceneクラスのインスタンスオブジェクトを返す
+(id)scene {
    return( [ [ [ self alloc ] init ] autorelease ] );
}


//初期化
-(id) init
{
	if( (self=[super init])) {
        //layerのインスタンスを作成する
        MAPlayfieldLayer *layer = [MAPlayfieldLayer node];
        //layerを画面に追加する
        [self addChild: layer];
	}
	return self;
}

@end
