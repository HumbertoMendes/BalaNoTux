//
//  ActionLayer.h
//  testegame
//
//  Created by Patrick Tracanelli <patrick@ids.com.br>
//  Copyright 2011 FreeBSD Brasil LTDA. All rights reserved.
//

#import "cocos2d.h"

// AULA 2 - Passo 18
// SpriteArray.m e .h
#import "SpriteArray.h"
#define winSize [CCDirector sharedDirector].winSize
@interface CamadaAcao : CCLayer 
{
    
    int playerGame;
    
    CCLabelBMFont *_titulo1;
    CCLabelBMFont *_titulo2;
    CCLabelBMFont *_tituloGameOver;
    CCLabelBMFont *_labelLevel;

    NSInteger _vidas, forcaInimigo;
    CCLabelBMFont *_vidasLabel;

    NSInteger _score;
    CCLabelBMFont *_scoreLabel;

    Boolean _isGameActive, matouInimigo;
    CCLabelBMFont *_forcaInimigoLabel;
    
    // Titulo Inicio
    CCMenuItemLabel *clickInicio, *clickRestart, *jogarBeastie, *jogarHexley;
    
    // Spritesheet do jogo
    CCSpriteBatchNode * batchNode; 
    CCSprite * heroi;
    
    // Inimigo
    // AULA 2 - Passo 9
    double proximoInimigoCria;
    
    // AULA 2 - Passo 19
    // Array de inimigos
    SpriteArray * inimigosArray;
    
    // Aula 2 - Passo 26
    SpriteArray * balaArray;
    
    // AULA 4 (3 na apostila)
    // Aula 3 - Passo 1 variaveis Parallax
    CCParallaxNode *_backgroundGame;
    CCSprite *_obj1;
    CCSprite *_obj2;
    
    Boolean _isSubBossOnStage;
    Boolean _isSubBossDead;
    Boolean _isBossOnStage;
    Boolean _moveUp;
    CCSprite* _boss;
    
} 

+ (id)scene;
-(void)configuraJogo;
-(void)adicionaBoss;
-(void)adicionaSubBoss;
-(void)adicionaGenericBoss:(float)scale forca:(int)forca tag:(int)tag;
-(void)adicionaInimigoSimples;
-(void)criaInimigo:(CCSprite*)inimigo scale:(float)scale forca:(int)forca tag:(int)tag position:(CGPoint)position sequenciaInimigo:(CCSequence*)sequenciaInimigo;
//-(void)addParticle:(NSString*)image startSize:(float)startSize endSize:(float)endSize speed:(float)speed lifeVar:(float)lifeVar duration:(float)duration position:(CGPoint)position z:(int)z tag:(enum MinhasParticulas)tag;
@end