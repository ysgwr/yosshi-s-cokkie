//
//  MAPlayfieldLayer.m
//  ch2-match3
//  Creating Games with cocos2d for iPhone 2
//
//  Copyright 2012 Paul Nygard
//

//================================================================================
//宣言・初期化
//================================================================================

#import "MAPlayfieldLayer.h"



#define SND_SWOOSH @"swoosh.caf"
#define SND_DING @"ding.caf"
#define WIDTH (45)

//後で変更
#define STARTX (100)

//後で変更
#define STARTY (100)

@implementation MAPlayfieldLayer

@synthesize playerScore;
//初期化
-(id) init {
	
    if (self == [super init]) {
        //タッチ検知の活動化
        self.isTouchEnabled = YES;
        
        //CCDirectorからウィンドウサイズを取得
        size = [[CCDirector sharedDirector] winSize];
        
        // Add our background image
        //バックグラウンドのイメージ追加
        CCSprite *bg = [CCSprite spriteWithFile:
                        @"match3bg.png"];
        //中心にポジション
        [bg setPosition:ccp(size.width/2,size.height/2)];
        //最背面にCCSPrite bgを追加
        [self addChild:bg z:0];
        
        // Load the spritesheet
        //スプライトのスプレッドシートのロード
        [[CCSpriteFrameCache sharedSpriteFrameCache]
         addSpriteFramesWithFile:@"match3sheet.plist"];
        //スプライトのシートを指定
        //複数のSpriteを表示するためSpriteBatchNodeを使っている
        matchsheet = [CCSpriteBatchNode batchNodeWithFile:
                      @"match3sheet.png" capacity:54];
        // Add the batch node to the layer
        //matchsheetを追加
        [self addChild:matchsheet z:1];
        
        // Add the back Button to the UI, bottom left
        //右下にバックのボタンを設置する
        backButton = [CCSprite spriteWithSpriteFrameName:
                      @"backbutton.png"];
        //アンカーポイントを設置
        //ccpはccpはcocos2dの便利マクロらしく、CGPointをMakeしてくれる
        [backButton setAnchorPoint:ccp(0,0)];
        [backButton setScale:0.7];
        [backButton setPosition:ccp(10, 10)];
        [matchsheet addChild:backButton];
        
        // Initialize the sizing of the board
        //ボードの初期化
        //6列
        boardRows = 5;
        //boardRows = 18;
        //boardRows = 10;
        
        
        //7行
        //boardColumns = 7;
        boardColumns = 18;
        //boardColumns = 10;
        
        //幅70
        //boardOffsetWidth = 70;
        boardOffsetWidth = -280;
        
        
        //高さ
        boardOffsetHeight = 0;
        //boardOffsetHeight = -300;
        
        
        padWidth = 4;
        padHeight = 4;
        
        //gemのサイズ45×45
        gemSize = CGSizeMake(45,45);
        
        // Total number of unique gems in the game
        //gemの種類数：7種
        totalGemsAvailable = 7;
        
        // Initialize the arrays
        //配列の初期化
        gemsInPlay = [[CCArray alloc] init];
        gemMatches = [[CCArray alloc] init];
        gemsTouched = [[CCArray alloc] init];
        //values = [[CCArray alloc] init];

        
        // Set the score to zero
        //プレイスコアの初期化
        playerScore = 0;
        
        //
        isGameOver = NO;
        
        
        //CGPoint startLocation,lastLocation;
        startLocation = CGPointZero;
        lastLocation = CGPointZero;
        
        // Preload the sound effects
        //音響効果の先行読み込み
        [self preloadEffects];
        
        // Add the score display to the screen
        //スコア表示
        [self generateScoreDisplay];
        
        // Add the timer display to the screen
        //タイマー表示
        [self generateTimerDisplay];
        startingTimerValue = 60; // 1 minute
        currentTimerValue = startingTimerValue;
        
        //プレイ画面表示
        [self generatePlayfield];
        
        //[self generateTestingPlayfield];  /// FOR DEBUGGING ONLY
        //[self drawGemMap:gemsInPlay];  /// FOR DEBUGGING ONLY
        
        [self checkMovesRemaining];
        
        [self scheduleUpdate];
    }
    return self;
}


//メモリの解放
-(void) dealloc {
    
    self.isTouchEnabled = NO;
    
    //gemsInPlayを削除
    [gemsInPlay removeAllObjects];
    [gemsInPlay release];
    gemsInPlay = nil;
    
    //gemMatchesを削除
    [gemMatches removeAllObjects];
    [gemMatches release];
    gemMatches = nil;
    
    //gemsTouchedを削除
    [gemsTouched removeAllObjects];
    [gemsTouched release];
    gemsTouched = nil;
    
    [super dealloc];
}

#pragma mark Object Positioning
//行列のポジションを定義する
-(CGPoint) positionForRow:(NSInteger)rowNum andColumn:(NSInteger)colNum {
    float x = boardOffsetWidth + ((gemSize.width + padWidth) * colNum);
    float y = boardOffsetHeight + ((gemSize.height + padHeight) * rowNum);
    return ccp(x,y);
}


#pragma mark Sound Effects
//ロード前に音楽ファイルを読み込む
-(void) preloadEffects {
    //SND_SWOOSHを読み込む
    [[SimpleAudioEngine sharedEngine]
     preloadEffect:SND_SWOOSH];
    
    //SND_DINGを読み込む
    [[SimpleAudioEngine sharedEngine]
     preloadEffect:SND_DING];
}
#pragma mark onEnter/onExit
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


//================================================================================
//データ操作
//================================================================================

//<ActionScriptあり>
/*
//④隣接リスト作成に相当
//8×8でgemを描写する
-(void) drawGemMap:(CCArray*)sourceArray {
    // Brute force debugger, produces a grid of numbers in the output window
    NSInteger map[8][8];
    
    for (int i = 1; i< 8; i++) {
        for (int j = 1; j < 8; j++) {
            map[i][j] = 0;
        }
    }
    
    for (MAPlayfieldSprite *aGem in sourceArray) {
        map[aGem.rowNum][aGem.colNum] = (NSInteger)aGem.gemType;
    }
    
    NSString *map1 = [NSString stringWithFormat:@"%i %i %i %i %i %i %i", map[1][1], map[1][2], map[1][3], map[1][4], map[1][5],
                      map[1][6], map[1][7]];
    
    NSString *map2 = [NSString stringWithFormat:@"%i %i %i %i %i %i %i", map[2][1], map[2][2], map[2][3], map[2][4], map[2][5],
                      map[2][6], map[2][7]];
    NSString *map3 = [NSString stringWithFormat:@"%i %i %i %i %i %i %i", map[3][1], map[3][2], map[3][3], map[3][4], map[3][5],
                      map[3][6], map[3][7]];
    
    NSString *map4 = [NSString stringWithFormat:@"%i %i %i %i %i %i %i", map[4][1], map[4][2], map[4][3], map[4][4], map[4][5],
                      map[4][6], map[4][7]];
    
    NSString *map5 = [NSString stringWithFormat:@"%i %i %i %i %i %i %i", map[5][1], map[5][2], map[5][3], map[5][4], map[5][5],
                      map[5][6], map[5][7]];
    
    NSString *map6 = [NSString stringWithFormat:@"%i %i %i %i %i %i %i", map[6][1], map[6][2], map[6][3], map[6][4], map[6][5],
                      map[6][6], map[6][7]];
    
    //NSLog(@"%@", map6);
    //NSLog(@"%@", map5);
    //NSLog(@"%@", map4);
    //NSLog(@"%@", map3);
    //NSLog(@"%@", map2);
    //NSLog(@"%@", map1);
}

*/


//⑦スライドさせた分表示をアップデートに相当
//プレイ画面のオブジェクトの動きと時間をアップデートする
-(void) update:(ccTime)dt {
    //gemが動いていないとき
    gemsMoving = NO;
    
    // See if we have any gems currently moving
    //動いているgemを見つけるまでチェックしつづける
    for (MAPlayfieldSprite *aGem in gemsInPlay) {
        if (aGem.gemState == kGemMoving) {
            gemsMoving = YES;
            break;
        }
    }
    
    /*
    // If we flagged that we need to check the board
    //マッチしていたら、他に動いているgemがいないかチェックする
    if (checkMatches) {
        [self checkMove];
        [self checkMovesRemaining];
        checkMatches = NO;
    }
    */
    
    
    if (checkMatches) {
        //ゲームオーバーにする
        isGameOver = YES;
        [self gameOver];
        
        //結果画面のためのメソッド
        [self moveResultScene];

    }
    
    
    
    
    
    
    
    
    // Too few gems left.  Let's fill it up.
    // This will avoid any holes if our smartFill left
    // gaps, which is common on 4 and 5 gem matches.
    //ボード上の列と行のgemが少ない場合
    if ([gemsInPlay count] < boardRows * boardColumns &&
        gemsMoving == NO) {
        
        //gemを追加する
        [self addGemsToFillBoard];
    }
    
    // Update the timer value & display
    //現在時刻を100で割る
    currentTimerValue = currentTimerValue - dt;
    [timerDisplay setPercentage:(currentTimerValue / startingTimerValue) * 100];
    
    // Game Over / Time's Up
    //タイマーが0になったら
    if (currentTimerValue <= 0) {
        [self unscheduleUpdate];
        
        //ゲームオーバーにする
        isGameOver = YES;
        [self gameOver];
        
        //結果画面のためのメソッド
        [self moveResultScene];
    }
}



//<ActionScriptなし>
//マッチしそうなgemをあらかじめ除外する
-(void) fixStartingMatches {
    // This method checks for any possible matches
    // and will remove those gems. After fixing the gems,
    // we call this method again (from itself) until we
    // have a clean result
    [self checkForMatchesOfType:kGemNew];
    
    //もし、マッチングがある場合
    if ([gemMatches count] > 0) {
        
        //get the first matching gem
        //マッチング[aGem stopHighlightGem]しているものを格納
        MAPlayfieldSprite *aGem = [gemMatches objectAtIndex:0];
        
        
        
        //Build a replacement gem
        //別のgemを作成する
        [self generateGemForRow:[aGem rowNum] andColumn:
         [aGem colNum] ofType:kGemAnyType];
        
        //Destroy the original gem
        //もともとのgemを破棄
        [gemsInPlay removeObject:aGem];
        [gemMatches removeObject:aGem];
        
        // We recurse so we can see if the board is clean
        // When we have no gemMatches, we stop recursion
        [self fixStartingMatches];
    }
}


//スコアの数値を計算
-(void) incrementScore {
    // Increment the score and update the display
    playerScore++;
    [self updateScore];
}

//タイマーの時間を1秒加算
-(void) addTimeToTimer {
    // Add 1 second to the clock
    currentTimerValue = currentTimerValue + 1;
    
    // If we are full, take it back to maximum
    if (currentTimerValue > startingTimerValue) {
        currentTimerValue = startingTimerValue;
    }
}

#pragma mark Check After Move Is Made
//移動を感知し、マッチしていないかチェックする
-(void) checkMove {
    // A move was made, so check for potential matches
    [self checkForMatchesOfType:kGemIdle];
    
    // Did we have any matches?
    if ([gemMatches count] > 0) {
        // Iterate through all matched gems
        for (MAPlayfieldSprite *aGem in gemMatches) {
            // If the gem is not already in scoring state
            if (aGem.gemState != kGemScoring) {
                // Trigger the scoring & removal of gem
                [self animateGemRemoval:aGem];
            }
        }
        // All matches processed.  Clear the array.
        [gemMatches removeAllObjects];
        // If we have any selected/touched gems, we must
        // have made an incorrect move
    } else if ([gemsTouched count] > 0) {
        // If there was only one gem, grab it
        MAPlayfieldSprite *aGem = [gemsTouched objectAtIndex:0];
        
        int tempRowNumA,tempColNumA;
        tempRowNumA = aGem.rowNum;
        tempColNumA = aGem.colNum;
        //NSLog(@"tempColNumA=%d",tempColNumA);
        /*
        // If we had 2 gems in the touched array
        if ([gemsTouched count] == 2) {
            // Grab the second gem
            MAPlayfieldSprite *bGem = [gemsTouched objectAtIndex:1];
            // Swap them back to their original slots
           // [self swapGem:aGem withGem:bGem];
        } else {
            // If we only had 1 gem, stop highlighting it
            [aGem stopHighlightGem];
        }
         */
    }
    // Touches were processed.  Clear the touched array.
    [gemsTouched removeAllObjects];
}


//gemが空いている場所に新たにgemを入れる
-(void) addGemsToFillBoard {
    // Loop through all positions, see if we have a gem
    for (int i = 1; i <= boardRows; i++) {
        for (int j = 1; j <= boardColumns; j++) {
            
            BOOL missing = YES;
            
            //Look for a missing gem in each slot
            for (MAPlayfieldSprite *aGem in gemsInPlay) {
                if (aGem.rowNum == i && aGem.colNum == j
                    && aGem.gemState != kGemScoring) {
                    // Found a gem, not missing
                    missing = NO;
                }
            }
            
            // We didn't find anything in this slot.
            if (missing) {
                [self addGemForRow:i andColumn:j
                            ofType:kGemAnyType];
            }
        }
    }
    // We possibly changed the board, trigger match check
    checkMatches = YES;
}

#pragma mark Match Checking (actual board)
//水平のマッチと垂直のマッチを調べる
-(void) checkForMatchesOfType:(GemType)desiredGemState {
    // This method checks for any 3 in a row matches,
    // and stores the resulting "scoring matches" in
    // the gemMatches array
    
    // We use the desiredGemState parameter to check for
    // kGemIdle or kGemNew, depending on whether the
    // game is in play or if it is initial board creation
    
    /*今回は垂直のみチェック対象なのでコメント合うと
    // Let's look for horizontal matches
    for (MAPlayfieldSprite *aGem in gemsInPlay) {
        // Let's grab the first gem
        if (aGem.gemState == desiredGemState) {
            // If it is the desired state, let's look
            // for a matching neighbor gem
            for (MAPlayfieldSprite *bGem in gemsInPlay) {
                // If the gem is the same type and state,
                // in the same row, and to the right
                if ([aGem isGemSameAs:bGem] &&
                    [aGem isGemInSameRow:bGem] &&
                    aGem.colNum == bGem.colNum - 1 &&
                    bGem.gemState == desiredGemState) {
                    // Now we loop through again,
                    // looking for a 3rd in a row
                    for (MAPlayfieldSprite *cGem in gemsInPlay) {
                        // If this is the 3rd gem in a row
                        // in the desired state
                        if (aGem.colNum == cGem.colNum - 2 &&
                            cGem.gemState == desiredGemState) {
                            // Is the gem the same type
                            // and in the same row?
                            if ([aGem isGemSameAs:cGem] &&
                                [aGem isGemInSameRow:cGem]) {
                                // Add gems to match array
                                [self addGemToMatch:aGem];
                                [self addGemToMatch:bGem];
                                [self addGemToMatch:cGem];
                                break;
                            }
                        }
                    }
                }
            }
     
        }
     */
        // Let's look for vertical matches
        for (MAPlayfieldSprite *aGem in gemsInPlay) {
            // Let's grab the first gem
            if (aGem.gemState == desiredGemState) {
                // If it is the desired state, let's look for a matching neighbor gem
                for (MAPlayfieldSprite *bGem in gemsInPlay) {
                    // If the gem is the same type and state, in the same column, and above
                    if ([aGem isGemSameAs:bGem] &&
                        [aGem isGemInSameColumn:bGem] &&
                        aGem.rowNum == bGem.rowNum - 1 &&
                        bGem.gemState == desiredGemState) {
                        // Now we loop through again, looking for a 3rd in the column
                        for (MAPlayfieldSprite *cGem in gemsInPlay) {
                            // If this is the 3rd gem in a row in the desired state
                            if (bGem.rowNum == cGem.rowNum - 1 &&
                                cGem.gemState == desiredGemState) {
                                // Is the gem the same type and in the same column?
                                if ([bGem isGemSameAs:cGem] &&
                                    [bGem isGemInSameColumn:cGem]) {
                                    // Add gems to match array
                                    [self addGemToMatch:aGem];
                                    [self addGemToMatch:bGem];
                                    [self addGemToMatch:cGem];
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
//}


//gemが空いている場所に新たにgemを入れる
-(void) addGemToMatch:(MAPlayfieldSprite*)thisGem {
    // Only adds it to the array if it isn't already there
    if ([gemMatches indexOfObject:thisGem] == NSNotFound) {
        [gemMatches addObject:thisGem];
    }
}

//組み合わせのマッチングがけ
-(NSInteger) findMatcheswithA:(NSInteger)a
                         andB:(NSInteger)b
                         andC:(NSInteger)c
                         andD:(NSInteger)d
                         andE:(NSInteger)e {
    NSInteger matches = 0;
    
    // For each valuesing of (up to) 5 gems, we check to see if we have a 5 match,
    // a 4 match, or a 3 match out of these 5.  It is impossible to have more than 5
    // in a row because anything longer would already have a 3 match made, and been
    // scored.
    // If there are zeroes, we do NOT want to count that as a match.
    
    if (a == b && b == c && c == d && d == e &&
        a + b + c + d + e != 0) {
        // 5 match
        matches++;
    } else if (a == b && b == c && c == d  &&
               a + b + c + d != 0) {
        // 4 match (left)
        matches++;
    } else if (b == c && c == d && d == e &&
               b + c + d + e != 0) {
        // 4 match (right)
        matches++;
    } else if (a == b && b == c && a + b + c != 0) {
        // 3 match (left)
        matches++;
    } else if (b == c && c == d && b + c + d != 0) {
        // 3 match (mid)
        matches++;
    } else if (c == d && d == e && c + d + e != 0) {
        // 3 match (right)
        matches++;
    }
    return matches;
}


//ゲーム中に空いた場所にgemを埋める
//checkMovesRemainingmethodと似ているが、
//matchするかどうかを判断している点で異なる
-(void) smartFill {
    // This method controls all gem fillins during the game.
    // The structure is very similar to the checkMovesRemaining
    // method, except this is determining the best gems to fill
    // in that will be able to be matched.
    
    // In case we were scheduled, unschedule it first
    [self unschedule:@selector(smartFill)];
    
    // If anything is moving, we don't want to fill yet
    if (gemsMoving) {
        // We reschedule so we retry when gems are not moving
        [self schedule:@selector(smartFill) interval:0.05];
        return;
    }
    
    // If we have plenty of matches, use a random fill
    if (movesRemaining >= 6) {
        [self addGemsToFillBoard];
        return;
    }
    
    // Create a temporary C-style array
    // We make it bigger than the playfield on purpose
    // This way we can evaluate past the edges
    NSInteger map[12][12];
    
    // Make sure it is cleared
    for (int i = 1; i < boardRows + 5; i++) {
        for (int j = 1; j < boardColumns + 5; j++) {
            if (i > boardRows || j > boardColumns) {
                // If row or column is bigger than board,
                // assign a -1 value
                map[i][j] = -1;
            } else {
                // If it is on the board, zero it
                map[i][j] = 0;
            }
        }
    }
    
    // Load all gem types into it
    for (MAPlayfieldSprite *aGem in gemsInPlay) {
        // We don't want to include scoring gems
        if (aGem.gemState == kGemScoring) {
            map[aGem.rowNum][aGem.colNum] = 0;
        } else {
            // Assign the gemType to the array slot
            map[aGem.rowNum][aGem.colNum] = aGem.gemType;
        }
    }
    
    // Parse through the map, looking for zeroes
    for (int row = 1; row <= boardRows; row++) {
        for (int col = 1; col <= boardColumns; col++) {
            
            // We use "intelligent randomness" to fill
            // holes when close to running out of matches
            
            // Grid variables look like:
            //
            //        h
            //        e   g
            //      n a b c
            //      s o p t
            //
            
            // where "a" is the root gem we're testing
            
            GemType a = map[row][col];
            GemType b = map[row][col+1];
            GemType c = map[row][col+2];
            GemType e = map[row+1][col];
            GemType g = map[row+1][col+2];
            GemType h = map[row+2][col];
            GemType n = map[row][col-1];
            GemType o = map[row-1][col];
            GemType p = map[row-1][col+1];
            GemType s = map[row-1][col-1];
            GemType t = map[row-1][col+2];
            
            // Vertical hole, 3 high
            if (a == 0 && e == 0 && h == 0) {
                if ((int)p >= 1) {
                    [self addGemForRow:row andColumn:col
                                ofType:p];
                    [self addGemForRow:row+1 andColumn:col
                                ofType:p];
                    [self addGemForRow:row+2 andColumn:col
                                ofType:kGemAnyType];
                    [self checkMovesRemaining];
                    [self smartFill];
                    return;
                }
                
                if ((int)s >= 1) {
                    [self addGemForRow:row andColumn:col
                                ofType:s];
                    [self addGemForRow:row+1 andColumn:col
                                ofType:s];
                    [self addGemForRow:row+2 andColumn:col
                                ofType:kGemAnyType];
                    [self checkMovesRemaining];
                    [self smartFill];
                    return;
                }
                
                if ((int)n >= 1) {
                    [self addGemForRow:row andColumn:col
                                ofType:kGemAnyType];
                    [self addGemForRow:row+1 andColumn:col
                                ofType:n];
                    [self addGemForRow:row+2 andColumn:col
                                ofType:n];
                    [self checkMovesRemaining];
                    [self smartFill];
                    return;
                }
                
                if ((int)b >= 1) {
                    [self addGemForRow:row andColumn:col
                                ofType:kGemAnyType];
                    [self addGemForRow:row+1 andColumn:col
                                ofType:b];
                    [self addGemForRow:row+2 andColumn:col
                                ofType:b];
                    [self checkMovesRemaining];
                    [self smartFill];
                    return;
                }
            }
            
            
            // Horizontal hole, 3 high
            if (a == 0 && b == 0 && c == 0) {
                if ((int)o >= 1) {
                    [self addGemForRow:row andColumn:col
                                ofType:kGemAnyType];
                    [self addGemForRow:row andColumn:col+1
                                ofType:o];
                    [self addGemForRow:row andColumn:col+2
                                ofType:o];
                    [self checkMovesRemaining];
                    [self smartFill];
                    return;
                }
                
                if ((int)t >= 1) {
                    [self addGemForRow:row andColumn:col
                                ofType:t];
                    [self addGemForRow:row andColumn:col+1
                                ofType:t];
                    [self addGemForRow:row andColumn:col+2
                                ofType:kGemAnyType];
                    [self checkMovesRemaining];
                    [self smartFill];
                    return;
                }
                
                if ((int)e >= 1) {
                    [self addGemForRow:row andColumn:col
                                ofType:kGemAnyType];
                    [self addGemForRow:row andColumn:col+1
                                ofType:e];
                    [self addGemForRow:row andColumn:col+2
                                ofType:e];
                    [self checkMovesRemaining];
                    [self smartFill];
                    return;
                }
                
                if ((int)g >= 1) {
                    [self addGemForRow:row andColumn:col
                                ofType:g];
                    [self addGemForRow:row andColumn:col+1
                                ofType:g];
                    [self addGemForRow:row andColumn:col+2
                                ofType:kGemAnyType];
                    [self checkMovesRemaining];
                    [self smartFill];
                    return;
                }
            }
        }
    }
}


#pragma mark Match Checking (predictive)
//動かしたときの他のマッチのバリエーションを調べる
-(void) checkMovesRemaining {
    //This method is code-heavy and a little difficult to follow in places.
    //It converts the gemsInPlay array to a 2 dimensional C-style array.
    // This allows us to easily check neighbor gems.
    // We then iterate through every position on the board, starting with row 1, column 1.
    //For each position, we test swapping the current gem
    // with the neighbor to the right and the neighbor above it.
    // We then check for potential matches with this new (theoretical) board.
    // We record how many matches we can make if we move that gem, and then we
    // do the same for the next gem.
    //Note: we never actually change the board in this method.
    
    // We only experiment with the "map" array, which is no
    // longer in scope when we leave this method.
    
    
    //gemsInPlayの配列を2次元のC用の配列へ変換する
    //この配列により、隣のgemを容易にチェックできるようになる
    //これにより、ボード上のどの位置からでも第1列,第1行をスタート地点として、順次処理をする
    //どの位置でも、私たちは現在のgemとすぐ隣もしくはすぐ上のgemと入れ替える
    //それからこの(理論上)新しいボードで潜在的なマッチをチェックする
    //私たちは移動できるマッチがいくつあるか記録し、それから私たちは同様のことをすぐ隣のgemを行う
    //このメソッドを離れたときはもはやmap配列を対象とした実験をしているだけにすぎない
    //実際はボードを変更することはないのであしからず。
    NSInteger matchesFound = 0;
    NSInteger gemsInAction = 0;
    
    //Create a temporary C-style array
    //一時的なC用の配列を作成
    NSInteger map[12][12];
    
    //Make sure it is cleared
    //配列の確認
    for (int i = 1; i< 12; i++) {
        for (int j = 1; j < 12; j++) {
            map[i][j] = 0;
        }
    }
    
    //Load all gem types into it
    //すべてのgem typesを配列の中でロードする
    for (MAPlayfieldSprite *aGem in gemsInPlay) {
        
        if (aGem.gemState != kGemIdle) {
            //If gem is moving or scoring, fill with zero
            //もし、gemが動いているか得点していた場合は0でいっぱいにする
            map[aGem.rowNum][aGem.colNum] = 0;
            
            gemsInAction++;
        } else {
            map[aGem.rowNum][aGem.colNum] = aGem.gemType;
        }
    }
    
    //Loop through all slots on the board
    //すべてのボード上のスロットをループさせる
    for (int row = 1; row <= boardRows; row++) {
        for (int col = 1; col <= boardColumns; col++) {
            
            // Grid variables look like:
            //
            //        j
            //        h i
            //    k l e f g
            //    m n a b c d
            //        o p
            //        q r
            
            // where "a" is the root gem we're testing
            // The swaps we test are a/b and a/e
            // So we need to identify all possible matches
            // that those swaps could cause
            GemType a = map[row][col];
            GemType b = map[row][col+1];
            GemType c = map[row][col+2];
            GemType d = map[row][col+3];
            GemType e = map[row+1][col];
            GemType f = map[row+1][col+1];
            GemType g = map[row+1][col+2];
            GemType h = map[row+2][col];
            GemType i = map[row+2][col+1];
            GemType j = map[row+3][col];
            GemType k = map[row+1][col-2];
            GemType l = map[row+1][col-1];
            GemType m = map[row][col-2];
            GemType n = map[row][col-1];
            GemType o = map[row-1][col];
            GemType p = map[row-1][col+1];
            GemType q = map[row-2][col];
            GemType r = map[row-2][col+1];
            
            // deform the board-swap of a and b, test
            GemType newA = b;
            GemType newB = a;
            
            matchesFound = matchesFound +
            [self findMatcheswithA:h andB:e
                              andC:newA andD:o andE:q];
            matchesFound = matchesFound +
            [self findMatcheswithA:i andB:f
                              andC:newB andD:p andE:r];
            matchesFound = matchesFound +
            [self findMatcheswithA:m andB:n
                              andC:newA andD:0 andE:0];
            matchesFound = matchesFound +
            [self findMatcheswithA:newB andB:c
                              andC:d andD:0 andE:0];
            
            // Now we swap a and e, then test
            newA = e;
            GemType newE = a;
            
            matchesFound = matchesFound +
            [self findMatcheswithA:m andB:n
                              andC:newA andD:b andE:c];
            matchesFound = matchesFound +
            [self findMatcheswithA:k andB:l
                              andC:newE andD:f andE:g];
            matchesFound = matchesFound +
            [self findMatcheswithA:newA andB:o
                              andC:q andD:0 andE:0];
            matchesFound = matchesFound +
            [self findMatcheswithA:newE andB:h
                              andC:j andD:0 andE:0];
        }
    }
    
    // See if we have gems in motion on the board
    // Set the BOOL so other methods don't try to fix
    // any "problems" with a moving board
    gemsMoving = (gemsInAction > 0);
    movesRemaining = matchesFound;
}



//================================================================================
//描画処理
//================================================================================

//<ActionScriptあり>
#pragma mark Brute Force Debugging Tools


//⑧ピースのインスタンスを生成してフィールドに配置に相当
//ボードにプレイフィールドとランダムなgemをランダムに配置する
-(void) generatePlayfield {
    
    // Randomly select gems and place on the board
    // Iterate through all rows and columns
    //rowがboardRows以下の場合
    for (int row = 1; row <= boardRows; row++) {
        
        //colがboardColums以下の場合
        for (int col = 1; col <= boardColumns; col++) {
            
            //Generate a gem for this slot
            //gemを生産する
            [self generateGemForRow:row andColumn:col
                             ofType:kGemAnyType];
        }
    }
    // We check for matches now, and remove any gems
    // from starting in the scoring position
    //このとき、マッチングしていないか調べる
    [self fixStartingMatches];
    
    // Add the gems to the layer
    //あるgemが　　　の場合
    for (MAPlayfieldSprite *aGem in gemsInPlay) {
        [aGem setGemState:kGemIdle];
        [matchsheet addChild:aGem];
    }
}


//左の外側に隠れたGemを作成
-(void)generateOutOfPlayfieldLeft{
    for(int row=1;row<=boardRows;row++){
        for(int col=-7;col<=0;col++){
            [self generateGemForRow:row andColumn:col ofType:kGemAnyType];
        }
    }
    [self fixStartingMatches];
    for(MAPlayfieldSprite *aGem in gemsInPlay){
        [aGem setGemState:kGemIdle];
        [matchsheet addChild:aGem];
    }
}

//右の外側に隠れたGemを作成
-(void)generateOutOfPlayfieldRight{
    for(int row=1;row<=boardRows;row++){
        for(int col=-9;col<=16;col++){
            [self generateGemForRow:row andColumn:col ofType:kGemAnyType];
        }
    }
    [self fixStartingMatches];
    for(MAPlayfieldSprite *aGem in gemsInPlay){
        [aGem setGemState:kGemIdle];
        [matchsheet addChild:aGem];
    }
}




//⑧ピースのインスタンスを生成してフィールドに配置に相当
//gemを配置する
-(MAPlayfieldSprite*) generateGemForRow:(NSInteger)rowNum
                              andColumn:(NSInteger)colNum ofType:(GemType)newType {
    
    GemType gemNum;
    
    //新しいgemのタイプ同一でないならば
    if (newType == kGemAnyType) {
        // If we passed a kGemAnyType, randomize the gem
        
        gemNum = (arc4random() % totalGemsAvailable) + 1;
    } else {
        // If we passed another value, use that gem type
        gemNum = newType;
    }
    
    // Generate the sprite name
    //スプライト名生成
    NSString *spritename = [NSString stringWithFormat:
                            @"gem%i.png", gemNum];
    
    //Build the MAPlayfieldSprite, which is just an enhanced CCSprite
    
    MAPlayfieldSprite *thisGem = [MAPlayfieldSprite
                                  spriteWithSpriteFrameName:spritename];
    
    // Set the gem's vars
    [thisGem setRowNum:rowNum];
    [thisGem setColNum:colNum];
    [thisGem setGemType:(GemType)gemNum];
    [thisGem setGemState:kGemNew];
    [thisGem setGameLayer:self];
    
    // Set the position for this gem
    [thisGem setPosition:[self positionForRow:rowNum
                                    andColumn:colNum]];
    
    // Add the gem to the array
    [gemsInPlay addObject:thisGem];
    
    // We return the newly created gem, which is already
    // added to the gemsInPlay array
    // It has NOT been added to the layer yet.
    return thisGem;
}



//⑪マウスの移動量に合わせてピースを移動するに相当
//gemを新しい場所に配置する
-(void) moveToNewSlotForGem:(MAPlayfieldSprite*)aGem {
    //Set the gem's state to moving
    //gemの状態をmovingにする
    [aGem setGemState:kGemMoving];
    
    // Move the gem, play sound, let it rest
    CCMoveTo *moveIt = [CCMoveTo
                        actionWithDuration:0.2
                        position:[self positionForRow:[aGem rowNum]
                                            andColumn:[aGem colNum]]];
    CCCallFunc *playSound = [CCCallFunc
                             actionWithTarget:self
                             selector:@selector(playSwoosh)];
    //gemを動かさない
    CCCallFuncND *gemAtRest = [CCCallFuncND
                               actionWithTarget:self
                               selector:@selector(gemIsAtRest:) data:aGem];
    [aGem runAction:[CCSequence actions:moveIt,
                     playSound, gemAtRest, nil]];
}

//⑫もし動かす量が少なかったときにピースグループをもとに戻すに相当
//gemを動かすのをやめる
-(void) resetGemPosition:(MAPlayfieldSprite*)aGem {
    // Quickly snap the gem back to its desired position
    // Used after the gem stops animating
    [aGem setPosition:[self positionForRow:[aGem rowNum]
                                 andColumn:[aGem colNum]]];
}



//<ActionScriptなし>
//gemを追加で配置する
//列に
-(void) addGemForRow:(NSInteger)rowNum
//行に
           andColumn:(NSInteger)colNum
//新しいタイプで
              ofType:(GemType)newType {
    
    // Add a replacement gem
    
    MAPlayfieldSprite *thisGem = [self generateGemForRow:rowNum
                                               andColumn:colNum ofType:newType];
    
    // We reset the gem above the screen
    [thisGem setPosition:ccpAdd(thisGem.position,
                                ccp(0,size.height))];
    
    // Add the gem to the scene
    [self addChild:thisGem];
    
    // Drop it to the correct position
    [self moveToNewSlotForGem:thisGem];
}



//(マッチしてないときに)gemを動かさない

//moveToNewSlotForGemの@selectorで呼び出し
-(void) gemIsAtRest:(MAPlayfieldSprite*)aGem {
    // Reset the gem's state to Idle
    //gemStateをアイドリングにリセット
    [aGem setGemState:kGemIdle];
    
    // Identify that we need to check for matches
    checkMatches = YES;
}



//gemが消えるときのアニメーション

-(void) animateGemRemoval:(MAPlayfieldSprite*)aGem {
    // We swap the image to "boom", and animate it out
    CCCallFuncND *changeImage = [CCCallFuncND
                                 actionWithTarget:self
                                 selector:@selector(changeGemFace:) data:aGem];
    CCCallFunc *updateScore = [CCCallFunc
                               actionWithTarget:self
                               selector:@selector(incrementScore)];
    CCCallFunc *addTime = [CCCallFunc
                           actionWithTarget:self
                           selector:@selector(addTimeToTimer)];
    CCMoveBy *moveUp = [CCMoveBy actionWithDuration:0.3
                                           position:ccp(0,5)];
    CCFadeOut *fade = [CCFadeOut actionWithDuration:0.2];
    /*
    CCCallFuncND *removeGem = [CCCallFuncND
                               actionWithTarget:self
                               selector:@selector(removeGem:) data:aGem];
    */
    [aGem runAction:[CCSequence actions:changeImage,
                     updateScore, addTime, moveUp, fade,
                     /*removeGem,*/ nil]];
}


//gemが消えるときboom.pngと入れ替える

-(void) changeGemFace:(MAPlayfieldSprite*)aGem {
    // Swap the gem texture to the "boom" image
    [aGem setDisplayFrame:[[CCSpriteFrameCache
                            sharedSpriteFrameCache]
                           spriteFrameByName:@"boom.png"]];
}


//gemを消す(コメントアウト)
/*
-(void) removeGem:(MAPlayfieldSprite*)aGem {
    // Clean up after ourselves and get rid of this gem
    [gemsInPlay removeObject:aGem];
    [aGem setGemState:kGemScoring];
    [self fillHolesFromGem:aGem];
    [aGem removeFromParentAndCleanup:YES];
    checkMatches = YES;
}
*/

#pragma mark Scoring
//スコアを表示
-(void) generateScoreDisplay {
    // Create the word "score"
    CCLabelTTF *scoreTitleLbl = [CCLabelTTF
                                 labelWithString:@"SCORE" fontName:@"Marker Felt"
                                 fontSize:20];
    [scoreTitleLbl setPosition:ccpAdd([self scorePosition],
                                      ccp(0,20))];
    [self addChild:scoreTitleLbl z:2];
    
    // Generate the display for the actual numeric score
    scoreLabel = [CCLabelTTF labelWithString:[NSString
                                              stringWithFormat:@"%i", playerScore]
                                    fontName:@"Marker Felt" fontSize:18];
    [scoreLabel setPosition:[self scorePosition]];
    [self addChild:scoreLabel z:3];
}


//スコアの数値を更新
-(void) updateScore {
    // Update the score label with the new score value
    [scoreLabel setString:[NSString stringWithFormat:@"%i",
                           playerScore]];
}


#pragma mark Timer & Game Over
//タイマー表示
-(void) generateTimerDisplay {
    
    // Add a frame for the timer
    CCSprite *timerFrame = [CCSprite
                            spriteWithFile:@"timer.png"];
    [timerFrame setPosition:[self timerPosition]];
    [self addChild:timerFrame z:8];
    
    // Create a sprite for the timer
    CCSprite *timerSprite = [CCSprite
                             spriteWithFile:@"timer_back.png"];
    
    // Add the timer itself
    timerDisplay = [CCProgressTimer
                    progressWithSprite:timerSprite];
    [timerDisplay setPosition:[self timerPosition]];
    [timerDisplay setType:kCCProgressTimerTypeRadial];
    [self addChild:timerDisplay z:4];
    
    [timerDisplay setPercentage:100];
}

//gameoverと表示する
-(void) gameOver {
    // Add a basic Game Over text
    CCLabelTTF *gameOverLabel = [CCLabelTTF
                                 labelWithString:@"Game Over"
                                 fontName:@"Marker Felt"
                                 fontSize:60];
    [gameOverLabel setPosition:ccp(size.width/2,
                                   size.height/2)];
    [self addChild:gameOverLabel z:50];
    
    // Add a second Game Over text, as a simple drop shadow
    CCLabelTTF *gameOverLabelShadow = [CCLabelTTF
                                       labelWithString:@"Game Over"
                                       fontName:@"Marker Felt" fontSize:60];
    [gameOverLabelShadow setPosition:ccp(size.width/2 - 4,
                                         size.height/2 - 4)];
    [gameOverLabelShadow setColor:ccBLACK];
    [self addChild:gameOverLabelShadow z:49];
}


//コレクション画面への遷移
-(void) moveResultScene {
    [[CCDirector sharedDirector] replaceScene:[MAResultScene scene]];
}



#pragma mark Gem Dropping
//このメソッドは消えてしまった部分の穴を満たすためのものである。
-(void) fillHolesFromGem:(MAPlayfieldSprite*)aGem {
    //aGemはマッチングし、消えてしまったものを指す。
    
    for (MAPlayfieldSprite *thisGem in gemsInPlay) {
        //もし、thisGemがマッチングして消えてしまったgem
        //と同じ行番号かつ上に位置していた場合
        //thisGemの位置を落とし、空いた穴を満たす
        if (aGem.colNum == thisGem.colNum &&
            aGem.rowNum < thisGem.rowNum) {
            // Set thisGem to drop down one row
            //thisGemを列番号を-1し、落とす
            [thisGem setRowNum:thisGem.rowNum - 1];
            [self moveToNewSlotForGem:thisGem];
        }
    }
    
    // Call the smart fill method.
    // If we do NOT want artifical randomness, comment
    // out this one call to smartFill, and everything
    // will be back to completely random gems.
    [self smartFill];
}

//スコアの位置を指定する
-(CGPoint) scorePosition {
    return ccp(50, size.height - 50);
}

//タイマーのポジション
-(CGPoint) timerPosition {
    return ccp(50, size.height/2);
}


//================================================================================
//ユーザ操作処理
//================================================================================
//<ActionScriptあり>
-(int)determineDirection:(CGPoint) convLoc start:(CGPoint)startlocation{
    //NSLog(@"convLocX:%f convLocY:%f", convLoc.x, convLoc.y);
    //NSLog(@"startlocationX:%f startlocationY:%f", startlocation.x, startlocation.y);
    CGPoint diff ={(convLoc.x - startlocation.x),(convLoc.y - startlocation.y)};
    //NSLog(@"diffX:%f diffY:%f", diff.x, diff.y);
    int retVal = 0;
    
    //if(abs(diff.x) > abs(diff.y)){
        if(diff.x > 0){
            //enumでUP=1,DOWN=2,RIGHT=3,LEFT=4としている
            //retVal = 3;
            retVal = RIGHT;
            //NSLog(@"retVal=%d",retVal);
        
        }
        else
            //retVal =4;
            retVal = LEFT;
        /*
         //}else{
         //if(diff.y>0){
         //retVal = 1
         //retVal = UP;
         //}else
         //retVal = 2
         //retVal = DOWN;
         
    }*/
    //NSLog(@"%d",retVal);
    return retVal;
}


-(CCArray*)blockCanMove:(MAPlayfieldSprite*)aGem{
    int tempRowNumA,tempColNumA;
    tempRowNumA = aGem.rowNum;
    tempColNumA = aGem.colNum;
    
    CCArray *values = [[[CCArray alloc]initWithCapacity:0]autorelease];
    //NSLog(@"tempColNumA=%d",tempRowNumA);
    for (MAPlayfieldSprite *bGem in gemsInPlay) {
        for(int i=1; i<=18; i++){
            if([aGem isGemInSameRow:bGem]&& bGem.colNum == i){
                [values addObject:bGem];
            }
        }
    }
    //int valuesCount = 0;
    //valuesCount = [values count];
    //NSLog(@"valuesCount=%d",valuesCount);
    return values;
}

/*
-(void)moveBlocks:(UITouch *)touch withEvent:(UIEvent *)event with:(CGPoint)location andGem:(MAPlayfieldSprite*)aGem with:(CCArray*)values{
    
    //自タイルをタッチしている場合
    //CGPoint location = [touch locationInView:[touch view]];
    //cocos2d座標に変換し記録する
    CGPoint convLoc = [[CCDirector sharedDirector] convertToGL:location];
    //NSLog(@"convLoc:%f", convLoc.x);
    
    directionMoving = [self determineDirection:convLoc start:startLocation];
    //NSLog(@"%d",directionMoving);
    [aGem highlightGem];
    int x = aGem.rowNum;
    //int y = aGem.colNum;
    switch(directionMoving){
        case RIGHT:{
            int diff = location.x - lastLocation.x;
            //NSLog(@"pointX:%f pointY:%f", convLoc.x, convLoc.y);
            //NSLog(@"pointX:%d", diff);
            
            
            //CGPoint pos = moving.position;
            CGPoint pos = aGem.position;
            
            pos.x +=diff;
            NSLog(@"posX:%f", pos.x);
            
            if((pos.x >=(STARTX + (WIDTH*x) && (abs(pos.x-(STARTX+WIDTH*x)))<=WIDTH))){
                for(MAPlayfieldSprite *aGem in gemsInPlay){
                    if([aGem containsTouchLocation:convLoc]&& aGem.gemState == kGemIdle){
                        //CCArray *slidevalues = [self blockCanMove:aGem];
                        
                        
                        //for(int x=0;x<values.count;x++){
                        for(int x=0; x < values.count ; x++){
                            
                            //CCSprite *current = [[values objectAtIndex:x]intValue];
                            CCSprite *current = [values objectAtIndex:x];
                            CGPoint pos1 = current.position;
                            pos1.x = diff;
                            [current setPosition:pos1];
                        }
                    }
                }
            }
            break;
            
        case LEFT:{
            int diff = location.x - lastLocation.x;
            //CGPoint pos = moving.position;
            CGPoint pos = aGem.position;
            pos.x +=diff;
            
            if((pos.x <=(STARTX + (WIDTH*x) && (abs(pos.x-(STARTX+WIDTH*x)))<=WIDTH))){
                
                 values = [self blockCanMove:aGem];
                 //for(int x=0;x<values.count;x++){
                 for(int x=1;x<18;x++){
                 //CCSprite *current = [[values objectAtIndex:x]intValue];
                 CCSprite *current = [values objectAtIndex:x];
                 CGPoint pos1 = current.position;
                 pos1.x = diff;
                 [current setPosition:pos1];
                 }
                 
            }
        }
        }
            
    }
}
*/


-(void)moveBlocks:(CGPoint)location andGem:(MAPlayfieldSprite*)aGem {
    //CCSprite *moving = [gemsInPlay objectAtIndex:aGem];
    
    //[aGem highlightGem];
    int x = aGem.rowNum;
    //NSLog(@"x:%d", x);
    
    //int direction = directionMoving;
    //int y = aGem.colNum;
    //NSLog(@"directionMoving(moveBlocks):%d", directionMoving);
    switch(directionMoving){
    //switch(direction){

        case RIGHT:{
            NSLog(@"aGem:%f", aGem.position.x);
            NSLog(@"location:%f", location.x);
            NSLog(@"lastlocation:%f", lastLocation.x);

            
            //int diff = location.x - lastLocation.x;
            float diff = location.x - lastLocation.x;
            
            
            //CGPoint diff2 = [[CCDirector sharedDirector]convertToGL:diff];

            
            //int diff2 = diff/30;
            //NSLog(@"diff:%d", diff);
            
            CGPoint pos = aGem.position;
            //pos.x +=diff2;
            pos.x +=diff;
            
            //NSLog(@"posX:%f", pos.x);
            
            if((pos.x >=(STARTX + (WIDTH*x) && (abs(pos.x-(STARTX+WIDTH*x)))<=WIDTH))){
                //for(MAPlayfieldSprite *aGem in gemsInPlay){
                //if([aGem containsTouchLocation:convLoc]&& aGem.gemState == kGemIdle){
                CCArray *allMoving = [self blockCanMove:aGem];
                
                int allMovingCount = 0;
                allMovingCount = [allMoving count];
                NSLog(@"allMovingCount=%d",allMovingCount);

                for(int x=1; x<allMoving.count; x++){
                    CCSprite *current = [allMoving objectAtIndex:x];
                    
                    //CGPoint pos1 = current.position;
                    CGFloat posx = current.position.x + diff;
                    
                    current.position = ccp(posx, current.position.y);
                    
                    
                    
                    //CGPoint pos2 = [[CCDirector sharedDirector]convertToGL:pos1];
                    //pos1.x += diff;
                    //pos1.x += diff;
                    NSLog(@"diff:%d", diff);
                    //current.position =ccp(pos1.x,pos1.y);
                    //[current setPosition:pos1];
                //}
            }
            
        }
        }
        break;
            
        case LEFT:{
            int diff = location.x - lastLocation.x;
            //CGPoint pos = moving.position;
            CGPoint pos = aGem.position;
            pos.x +=diff;
            
            if((pos.x <=(STARTX + (WIDTH*x) && (abs(pos.x-(STARTX+WIDTH*x)))<=WIDTH))){
                //for(MAPlayfieldSprite *aGem in gemsInPlay){
                //if([aGem containsTouchLocation:convLoc]&& aGem.gemState == kGemIdle){
                CCArray *allMoving = [self blockCanMove:aGem];
                    
                for(int x=1; x<allMoving.count; x++){
                    CCSprite *current = [allMoving objectAtIndex:x];
                    CGPoint pos1 = current.position;
                    pos1.x += diff;
                    [current setPosition:pos1];
                }
            }
        }
    }
}




//タッチして、どのボタンが押されたかを処理する
-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    //自タイルをタッチしている場合
    CGPoint location = [touch locationInView:[touch view]];
    //cocos2d座標に変換し記録する
    CGPoint convLoc = [[CCDirector sharedDirector]
                       convertToGL:location];
    
    //NSLog(@"convLoc:%f", convLoc.x);
    
    // If we reached game over, any touch returns to menu
    //gameoverになって、「menuへ戻る」を選択したら
    if (isGameOver) {
        [[CCDirector sharedDirector]
         replaceScene:[MAMenuScene scene]];
        return YES;
    }
    
    // If the back button was pressed, we exit
    //「menuへ戻る」を選択したら
    if (CGRectContainsPoint([backButton boundingBox],
                            convLoc)) {
        [[CCDirector sharedDirector]
         replaceScene:[MAMenuScene node]];
        return YES;
    }    
    // If we have only 0 or 1 gem in gemsTouched, track
    //タッチしたgemの数が0か1なら
    if ([gemsTouched count] < 2) {
        // Check each gem
        //すべてのgemをチェックし続ける
        //for文の型:高速列挙構文
        //for(取り出す変数の型 取り出す変数名 in コレクションクラス)
        /*
        for (MAPlayfieldSprite *aGem in gemsInPlay) {
            //If the gem was touched AND the gem is idle,
            //return YES to track the touch
            //もし、gemがタッチされ、状態が保留中なら
            //YESをreturnし、トラッキングし続ける
            if ([aGem containsTouchLocation:convLoc] &&
                aGem.gemState == kGemIdle) {
                return YES;
            }
         */
        /*
        for (MAPlayfieldSprite *aGem in gemsInPlay) {
            if ([aGem containsTouchLocation:convLoc] &&
                aGem.gemState == kGemIdle) {
                values = [self blockCanMove:aGem];
                directionMoving = -1;
                startLocation = convLoc;
                
                //int valuesCount = 0;
                //valuesCount = [values count];
                //NSLog(@"valuesCount=%d",valuesCount);
                
                return YES;
            }
        }
         */
        directionMoving = -1;
        startLocation = location;
        lastLocation = location;
        return YES;
         
       // }
    }
    // If we failed to find any good touch, return
    return NO;
}

//タッチが動かされているときの処理
-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    //自タイルをタッチしている場合
    CGPoint location = [touch locationInView:[touch view]];
    //cocos2d座標に変換し記録する
    CGPoint convLoc = [[CCDirector sharedDirector] convertToGL:location];

    for (MAPlayfieldSprite *aGem in gemsInPlay) {
        if ([aGem containsTouchLocation:convLoc] && aGem.gemState == kGemIdle) {
            //values = [self blockCanMove:aGem];
            CCArray *moved = [self blockCanMove:aGem];
            
            //determine if the sprite is movable in the direction it is trying to move and move it if true
            //スプライトが動かしている方向に対して動かせるかを考える
            //determine direction moving if not already determined
            //すでに動く方向が決まっていなかった場合
            if(directionMoving == -1)
                directionMoving = [self determineDirection:(CGPoint)convLoc start:(CGPoint)startLocation];
            NSLog(@"directionMoving(ccTouchMoved):%d", directionMoving);
            
            if([self blockCanMove:aGem]){
                //startLocation = convLoc;
                //values = [self blockCanMove:aGem:location:values];
                //int valuesCount = 0;
                //valuesCount = [values count];
                //NSLog(@"valuesCount=%d",valuesCount);
                //[aGem highlightGem];
                [self moveBlocks:(CGPoint)location andGem:(MAPlayfieldSprite*)aGem];
            }
        }
    }
}


//タッチが終わったときの処理(改)
-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    // Taps are handled here.
    //タップはここで処理
    //バグるのでコメントアウト
    //[self touchHelper:touch withEvent:event];

    CGPoint location = [touch locationInView:[touch view]];
    CGPoint convLoc = [[CCDirector sharedDirector] convertToGL:location];

    if(currentlyMoving > 0){

        int distanceMoved = 0;
        if(distanceMoved>0){
            
            for (MAPlayfieldSprite *aGem in gemsInPlay) {
                if ([aGem containsTouchLocation:convLoc] && aGem.gemState == kGemIdle) {
                    values = [self blockCanMove:aGem];
                    CCArray *moved;
                    //*moved = *values;
                    moved = [self blockCanMove:aGem];
                    int mistance =0;
                    switch (directionMoving) {
                        case UP:
                        case DOWN:
                            distanceMoved = abs(location.y-startLocation.y);
                            break;
                        case RIGHT:
                        case LEFT:
                            distanceMoved = abs(location.x-startLocation.x);
                            break;
                    }
                    
                    if(distanceMoved >=(WIDTH/2)){
                        for(int z =0;z<[values count];z++){
                            int object =[[moved objectAtIndex:z]intValue];
                            int x = (object/5);
                            int y = (object/18);
                            CGPoint endPosition;
                    
                            switch (directionMoving) {
                                case RIGHT:{endPosition = ccp(STARTX + (WIDTH*(x+1)),(STARTY - (WIDTH*y)));}break;
                                case LEFT:{endPosition = ccp(STARTX + (WIDTH*(x-1)),(STARTY - (WIDTH*y)));}break;
                            }
                            [[gemsInPlay objectAtIndex:object] runAction :[CCMoveTo actionWithDuration:0.1 position:endPosition ]];
                        }
                    }
                    else if(distanceMoved < (WIDTH/2)){
                        for(int z ;[moved count];z++){
                            int object =[[moved objectAtIndex:z]intValue];
                            int x=(object/5);
                            int y=(object/18);
                            CGPoint endPosition;
                            
                            switch (directionMoving) {
                                case RIGHT: {endPosition = ccp(STARTX+(WIDTH*(x)), STARTY-(WIDTH*y));} break;
                                case LEFT: {endPosition = ccp(STARTX+(WIDTH*(x)), STARTY-(WIDTH*y));} break;
                            }
                            [[gemsInPlay objectAtIndex:object] runAction :[CCMoveTo actionWithDuration:0.1 position:endPosition ]];
                        }
                    }
                }
                [aGem stopHighlightGem];
            }
        }
    }
    //この下3行はスライドのための追加分
    //reset everything
    directionMoving = currentlyMoving = -1;
    startLocation = lastLocation = CGPointZero;
}


//<ActionScriptなし>


//================================================================================
//その他
//================================================================================

//音楽ファイルをSND_SWOOSH再生する
-(void) playSwoosh {
    [[SimpleAudioEngine sharedEngine]
     playEffect:SND_SWOOSH
     pitch:1.0 pan:0 gain:0.25];
}

//音楽ファイルSND_DINGを再生する
-(void) playDing {
    [[SimpleAudioEngine sharedEngine]
     playEffect:SND_DING];
}



@end




