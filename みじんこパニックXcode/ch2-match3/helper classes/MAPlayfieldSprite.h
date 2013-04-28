//
//  MAPlayfieldSprite.h
//  ch2-match3
//  Creating Games with cocos2d for iPhone 2
//
//  Copyright 2012 Paul Nygard
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class MAPlayfieldLayer;

//列挙型
//typedefは既にある型に対して新しい名前を作成するもの
//一番先頭を0にして続く項目が+1、+1.... されていく
//下の場合はkGemAnyType = 0なので
//  kGem1=1
//  kGem2=2
//となる

typedef enum {
    kGemAnyType = 0,
    kGem1,
    kGem2,
    kGem3,
    kGem4,
    kGem5,
    kGem6,
    kGem7
} GemType;
//GemType型を定義した



typedef enum {
    kGemIdle = 100,
    kGemMoving,
    kGemScoring,
    kGemNew
} GemState;
//GemState型を定義した

@interface MAPlayfieldSprite : CCSprite {
    
    //Row number for this gem
    //this gemの列番号
    NSInteger _rowNum;
    
    //Column number for this gem
    //this gemの行番号
    NSInteger _colNum; 
    
    //The enum value of the gem
    //gemの列挙型
    GemType _gemType; 
    
    //The current state of the gem
    //gem現在の状態
    GemState _gemState; 

    //The game layer
    //gemeLayerの宣言
    MAPlayfieldLayer *gameLayer;
    
}

//他クラスの変数へアクセスするためのプロパティ宣言
@property (nonatomic, assign) NSInteger rowNum;
@property (nonatomic, assign) NSInteger colNum;
@property (nonatomic, assign) GemType gemType;
@property (nonatomic, assign) GemState gemState;
@property (nonatomic, assign) MAPlayfieldLayer *gameLayer;

//-(戻り値の型)メソッド名:(型名)パラメータ
-(BOOL) isGemSameAs:(MAPlayfieldSprite*)otherGem;
-(BOOL) isGemInSameRow:(MAPlayfieldSprite*)otherGem;
-(BOOL) isGemInSameColumn:(MAPlayfieldSprite*)otherGem;
-(BOOL) isGemBeside:(MAPlayfieldSprite*)otherGem;
-(BOOL) containsTouchLocation:(CGPoint)pos;
-(void) highlightGem;
-(void) stopHighlightGem;

@end
