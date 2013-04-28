//
//  MAResultScene.m
//  ch2-match3
//
//  Created by 鈴木 宏昌 on 13/04/01.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "MAResultScene.h"
#import "MAResultLayer.h"

@implementation MAResultScene

//Sceneクラスのインスタンスオブジェクトを返す
+(id)scene {
    return( [ [ [ self alloc ] init ] autorelease ] );
}


//初期化
-(id) init
{
	if( (self=[super init])) {
        
        //layerのインスタンスを作成する
        MAResultLayer *layer = [MAResultLayer node];
        
        //layerを画面に追加する
        [self addChild: layer];
	}
	return self;
}

@end
