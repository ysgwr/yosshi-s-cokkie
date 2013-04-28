//
//  MACollectionScene.m
//  ch2-match3
//
//  Created by 鈴木 宏昌 on 13/04/01.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "MACollectionScene.h"
#import "MACollectionLayer.h"


@implementation MACollectionScene

//Sceneクラスのインスタンスオブジェクトを返す
+(id)scene {
    return( [ [ [ self alloc ] init ] autorelease ] );
}


//初期化
-(id) init
{
	if( (self=[super init])) {
        //layerのインスタンスを作成する
        MACollectionLayer *layer = [MACollectionLayer node];
        //layerを画面に追加する
        [self addChild: layer];
	}
	return self;
}
@end
