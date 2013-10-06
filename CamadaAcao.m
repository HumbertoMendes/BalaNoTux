//
//  ActionLayer.m
//  testegame
//
//  Created by Patrick Tracanelli
//  Copyright 2011 FreeBSD Brasil LTDA. All rights reserved.
//

#import "CamadaAcao.h"
// SOM
#import "SimpleAudioEngine.h"

// Inimigo
// AULA 2 - Passo 10
#import "Common.h"

// Importa extras pra por loop no CCParallax
#import "CCParallaxNode-Extras.h"

@implementation CamadaAcao

enum MinhasParticulas {
    ParticulaFogo,
    particulaAcertouInimigo,
    particulaAcertouHeroi
};

enum Personagens {
    heroiTag
};

// AULA 2 - Passo 2
float heroiPontosPorSegY;

//Fator de scale para criacao dos objetos
double factorScale = 1.0;

+ (id)scene {
    CCScene *cena = [CCScene node];
    CamadaAcao *camada = [CamadaAcao node]; 
    [cena addChild:camada]; 
    return cena;
} 

// SOM
- (void)poeSom { 
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"patrick_soundtrack.mp3" loop:YES]; 
    
    // preload dos proximos sons
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"som_exemplo.mp3"];
}

// Particula Estrela
- (void)poeEstrela {
    NSArray *estrelinhas = [NSArray arrayWithObjects:
                           @"Stars1.plist", 
                           @"Stars2.plist",
                           @"Stars3.plist", nil];
    for(NSString *estrela in estrelinhas) {
        CCParticleSystemQuad *efeitoEstrela = [CCParticleSystemQuad
                                             particleWithFile:estrela];
        efeitoEstrela.position = ccp(winSize.width*1.5, winSize.height/2);
        efeitoEstrela.posVar = ccp(efeitoEstrela.posVar.x, (winSize.height/2) * 1.5);
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
            efeitoEstrela.scale = 0.5;
            efeitoEstrela.posVar = ccpMult(efeitoEstrela.posVar, 2.0);
        }
        [self addChild:efeitoEstrela];
    }
}


// Particula Chuva
-(void) poeChuva {
    
    CCParticleSystem* chovechuva = [CCParticleRain node];
    
    CGPoint p = chovechuva.position;
    
    chovechuva.position = ccp( p.x, p.y);
    chovechuva.life = 4;
    chovechuva.texture = [[CCTextureCache sharedTextureCache] addImage: @"gotaChuva.png"];
    chovechuva.startSize = 10.0f * factorScale;
    
    [self addChild: chovechuva z:10];

}

// Desliga Inicio e demais titulos
-(void)removeNode:(CCNode *)sender {
    [sender removeFromParentAndCleanup:YES];
}

// Lança e inicia (spawn) o protagonista adicionando um sprite dele no jogo
- (void)poeProtagonista {
    //0 = Beastie
    //1 = Hexley
    if (playerGame == 0) {
        heroi = [CCSprite spriteWithSpriteFrameName:@"beastie-down40.png"];
    }
    else
    {
        heroi = [CCSprite spriteWithSpriteFrameName:@"hexley40.png"];
        heroi.flipX = YES;
    }
    
    heroi.scaleY = 1.0 * factorScale;
    heroi.scaleX = 1.0 * factorScale;
    heroi.position = ccp(-heroi.contentSize.width/2,
                        winSize.height * 0.5);
    [batchNode addChild:heroi z:1 tag:heroiTag];
    [heroi runAction:
     [CCSequence actions:
      [CCEaseOut actionWithAction:
       [CCMoveBy actionWithDuration:0.5
                           position:ccp(heroi.contentSize.width/2 + winSize.width*0.3,
                                        0)]
                             rate:4.0],
      [CCEaseInOut actionWithAction:
       [CCMoveBy actionWithDuration:0.5
                           position:ccp(-winSize.width*0.2, 0)]
                               rate:4.0],
      nil]];
  
    // Anima o protagonista
    if(playerGame == 0)
    {
        CCSpriteFrameCache * cache = [CCSpriteFrameCache sharedSpriteFrameCache];
        CCAnimation *andaHeroi = [CCAnimation animation];
        [andaHeroi addFrame:
         [cache spriteFrameByName:@"beastie-down40.png"]];
        [andaHeroi addFrame:
         [cache spriteFrameByName:@"beastie-up40.png"]];
        [andaHeroi setDelay:0.2];
        [heroi runAction:
         [CCRepeatForever actionWithAction:
          [CCAnimate actionWithAnimation:andaHeroi]]];
    }
    
    
}

-(void)apertouRestart:(id)sender {
    NSLog(@"Clicou Restart: %d", _vidas);
    
    // Sai da funcao se nao estiver morto.
    if (_vidas >0 ) return;
    
    [self configuraJogo];    
    _isGameActive = TRUE;
    heroi.visible = TRUE;
    _tituloGameOver.scale = 0;
    clickRestart.scale = 0;
    _vidasLabel.string = [NSString stringWithFormat:@"Vidas: %d", _vidas];
}

// Inicio
- (void)apertouInicio:(id)sender {
    [[SimpleAudioEngine sharedEngine] playEffect:@"powerup.caf"];
    NSArray * nodes = [NSArray arrayWithObjects:_titulo1, _titulo2, clickInicio,jogarBeastie,jogarHexley,
                       nil];
    for (CCNode *node in nodes) {
        [node runAction:
         [CCSequence actions:
          [CCEaseOut actionWithAction:
           [CCScaleTo actionWithDuration:0.5 
                                   scale:0] rate:4.0],
          [CCCallFuncN actionWithTarget:self 
                               selector:@selector(removeNode:)],
          nil]];
    }
    
    // No final de apertouInicio ou seja quando clicar pra comecar
    // Adicionamos o protagonista na cena...
    [self poeProtagonista];
    
    _vidas = 3;
    _vidasLabel.string = [NSString stringWithFormat:@"Vidas: %d", _vidas];
    _vidasLabel.scale = 1.5 * factorScale;

    _score = 0;
    _scoreLabel.string = [NSString stringWithFormat:@"Score: %d", _score];
    _scoreLabel.scale = 1.5 * factorScale;
    
    _forcaInimigoLabel.string = [NSString stringWithFormat:@"Resist: %d", forcaInimigo];
    _forcaInimigoLabel.scale = 1.5 * factorScale;

    _isGameActive = true;
}

- (void)poeTitulo {
    
    //0 = Beastie
    //1 = Hexley
    playerGame = 0;
    
    NSString *fontName = @"fonteCasual.fnt";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        fontName = @"fonteCasual-hd.fnt";
    }
    
    _titulo1 = [CCLabelBMFont labelWithString:@"IDS Tecnologia" fntFile:fontName];
    // efeitos
    _titulo1.scale = 0;
    
    //_titulo1.scale = 0.5; 
    _titulo1.position = ccp(winSize.width/2, winSize.height * 0.8);
    [self addChild:_titulo1 z:100];
    
    // efeitos
    [_titulo1 runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:1.0],
      [CCScaleTo actionWithDuration:1.0 scale:2.5 * factorScale],
      nil]];
    
    _titulo2 = [CCLabelBMFont labelWithString:@"Bala no TuX!" fntFile:fontName];
    // efeitos
    _titulo2.scale = 0;

    //_titulo2.scale = 1.25; 
    _titulo2.position = ccp(winSize.width/2, winSize.height * 0.6);
    [self addChild:_titulo2 z:100];
    
    
    
    // efeitos
    [_titulo2 runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:1.0],
      [CCScaleTo actionWithDuration:1.0 scale:3.5 * factorScale],
      nil]];
    
    // titulo Inicio
    CCLabelBMFont *playLabel = [CCLabelBMFont labelWithString:@"Iniciar" fntFile:fontName];
    
    clickInicio = [CCMenuItemLabel itemWithLabel:playLabel 
                                       target:self
                                     selector:@selector(apertouInicio:)];
    [clickInicio setScale:0];
    
    [clickInicio setPosition:ccp(winSize.width/2, winSize.height * 0.3)];
    
    CCMenu *menu = [CCMenu menuWithItems:clickInicio, nil];
    [menu setPosition:CGPointZero];
    //menu.position = CGPointZero;
    [self addChild:menu];
    
    [clickInicio runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:2.0],
      [CCEaseOut actionWithAction:
       [CCScaleTo actionWithDuration:0.5 scale:2.5 * factorScale] rate:4.0],
      nil]];
    
    
    CCLabelBMFont *playBeastie = [CCLabelBMFont labelWithString:@"Jogar com Beastie" fntFile:fontName];
    
    jogarBeastie = [CCMenuItemLabel itemWithLabel:playBeastie
                                          target:self
                                        selector:@selector(jogarBestie:)];
    [jogarBeastie setScale:0];
    
    [jogarBeastie setPosition:ccp(winSize.width/6, winSize.height * 0.15)];
    
    
    CCLabelBMFont *playHexley = [CCLabelBMFont labelWithString:@"Jogar com Hexley" fntFile:fontName];
    
    jogarHexley = [CCMenuItemLabel itemWithLabel:playHexley
                                          target:self
                                        selector:@selector(jogarHexley:)];
    [jogarHexley setScale:0];
    
    [jogarHexley setPosition:ccp(winSize.width/6, winSize.height * 0.1)];
    
    CCMenu *menuPlayer = [CCMenu menuWithItems:jogarBeastie,jogarHexley, nil];
    [menuPlayer setPosition:CGPointZero];
    //menu.position = CGPointZero;
    [self addChild:menuPlayer];
    
    [jogarBeastie runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:2.0],
      [CCEaseOut actionWithAction:
       [CCScaleTo actionWithDuration:0.5 scale:1 * factorScale] rate:4.0],
      nil]];
    
    [jogarHexley runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:2.0],
      [CCEaseOut actionWithAction:
       [CCScaleTo actionWithDuration:0.5 scale:1 * factorScale] rate:4.0],
      nil]];
    
    
    // Vidas
    _vidasLabel = [CCLabelBMFont labelWithString:@"Vidas: x" fntFile:fontName];
    _vidasLabel.scale = 0;
    _vidasLabel.position = ccp(winSize.width/8, winSize.height * 0.95);
    [self addChild:_vidasLabel z:100];

    // Score
    _scoreLabel = [CCLabelBMFont labelWithString:@"Score: x" fntFile:fontName];
    _scoreLabel.scale = 0;
    _scoreLabel.position = ccp(winSize.width/8, winSize.height * 0.05);
    [self addChild:_scoreLabel z:100];
    
    // Força do Inimigo
    _forcaInimigoLabel = [CCLabelBMFont labelWithString:@"Resist: x" fntFile:fontName];
    _forcaInimigoLabel.scale = 0;
    _forcaInimigoLabel.position = ccp(winSize.width*0.85, winSize.height * 0.05);
    [self addChild:_forcaInimigoLabel z:100];

    // Game Over
    _isGameActive = false;
    _tituloGameOver = [CCLabelBMFont labelWithString:@"Restart" fntFile:fontName];
    _tituloGameOver.scale = 0; // Game Over fica invisivel
        
    //CCMenuItemLabel *itemRestart;
    clickRestart = [CCMenuItemLabel itemWithLabel:_tituloGameOver
                        target:self selector:@selector(apertouRestart:)];
    clickRestart.scale = 0;
    
    
    [clickRestart setPosition:ccp(winSize.width, winSize.height/2)];
    
    CGSize NovoTamanho = CGSizeMake(winSize.width, 100);
    // Vamos ;tentar corrigir o tamanho da area do click do menu...
    [clickRestart setContentSize:NovoTamanho];
    
    CCMenu *menuOver = [CCMenu menuWithItems:clickRestart, nil];
    [menuOver setPosition:CGPointZero];
    [self addChild:menuOver];
    
    /*[clickRestart runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:2.0],
      [CCEaseOut actionWithAction:
       [CCScaleTo actionWithDuration:0.5 scale:2.5] rate:4.0],
      nil]];*/


}

-(void) exibeLabelLevel:(int) level {
    NSString * texto = [NSString stringWithFormat:@"Level %d", level];
    
    NSString *fontName = @"fonteCasual.fnt";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        fontName = @"fonteCasual-hd.fnt";
    }
    _labelLevel = [CCLabelBMFont labelWithString:texto fntFile:fontName];
    // efeitos
    _labelLevel.scale = 0;
    
    //_titulo1.scale = 0.5;
    _labelLevel.position = ccp(winSize.width/2, winSize.height/2);
    [self addChild:_labelLevel z:100];
    
    // efeitos
    [_labelLevel runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:1.0],
      [CCScaleTo actionWithDuration:1.0 scale:2.5 * factorScale],
      [CCDelayTime actionWithDuration:3.0],
      [CCScaleTo actionWithDuration:1.0 scale:0],
      nil]];
}

- (void)colocaBatchNode {
    NSString *spritesImg = @"sprite_.png";
    NSString *spritesPlist = @"sprite_.plist";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        spritesImg = @"sprite_.png";
        spritesPlist = @"sprite_.plist";
        // deveria ser um arquivo de High Definition (-hd)
    }
    batchNode = [CCSpriteBatchNode batchNodeWithFile:spritesImg];
    [self addChild:batchNode z:-1];
    [[CCSpriteFrameCache sharedSpriteFrameCache]
     addSpriteFramesWithFile:spritesPlist];
}


// Inicia Array de Inimigos
// AULA 2 - Passo 20
- (void)setupArrays {
    inimigosArray = [[SpriteArray alloc] initWithCapacity:15
                                          spriteFrameName:[NSArray arrayWithObjects:
                                                           @"flyingtux40.png",
                                                           @"pengu40.png",
                                                           nil]
                                                 batchNode:batchNode];
    
    // Aula 2 - Passo 27
    balaArray = [[SpriteArray alloc] initWithCapacity:5
                                      spriteFrameName:[NSArray arrayWithObjects:
                                                       @"logo.png",
                                                       nil]
                                             batchNode:batchNode];
}

// AULA 4
- (void)poeBackgroundImg:(NSString *) fileName {
    _vidas = 1; // Quando apertar Inicio ou Restart tera 3 vidas
    
    // Passo 1, criamos o CCParallaxNode
    _backgroundGame = [CCParallaxNode node];
    [self addChild:_backgroundGame z:-2];
    
    // Passo2, vamos adicionar os sprites obj1 e 2 no 
    // parallax node...
    // Primeiro vamos testar se eh iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // Colocar nos objets parallax variasveis com arquivo
        // imagem, como eh iPad, HD
        _obj1 = [CCSprite spriteWithFile:fileName];
        _obj2 = [CCSprite spriteWithFile:@"nuvem.gif"];
        
        _obj1.scaleX = 4.0;
        _obj1.scaleY = 2.0;
        
    } else {
        _obj1 = [CCSprite spriteWithFile:fileName];
        _obj2 = [CCSprite spriteWithFile:@"nuvem.gif"];

        _obj1.scaleX = 2.0;
        _obj1.scaleY = 1.0;
        _obj2.scaleX = factorScale;
        _obj2.scaleY = factorScale;
    }
    
    // 3 passo determinar a velocidade relativa do bg
    CGPoint velocidadeObj = ccp(0.1,0.1);
    CGPoint velocidadeBg = ccp(0.05,0.05);
    
    // Passo 4 adiciona os objetos filho ao CC PArallax Node
    [ _backgroundGame addChild:_obj2 z:0 parallaxRatio:velocidadeObj positionOffset:ccp(winSize.width,winSize.height * 0.9)];
    
    // E agora mesma coisa no objeto1
    [_backgroundGame addChild:_obj1 z:-1 parallaxRatio:velocidadeBg positionOffset:ccp(0,winSize.height/2)];
    
}
- (void)trocaBackgroundImg:(NSString*) fileName {
    [_backgroundGame removeAllChildrenWithCleanup:true];
    [self poeBackgroundImg:fileName];
}

/*
 *
 * PROGRAMA PRINCIPAL
 *
 */
- (id)init {
    if ((self = [super init])) {

        [self configuraJogo];
        
        // Titulo
        [self poeTitulo];
        
        // SOM
        [self poeSom];
        
        // Particula
        //[self poeEstrela];
        [self poeChuva];
        
        // coloca o batch node com a arte
        [self colocaBatchNode];
        
        // Acelerometro
        // AULA 2 - Passo 1
        [self setIsAccelerometerEnabled:YES];
        
        // Agenda a chamada a funcao update
        // AULA 2 - Passo 6
        [self scheduleUpdate];
        
        // Coloca os arrays de inimigos na tela
        // AULA 2 - Passo 21
        [self setupArrays];
        
        // AULA 2 - Passo 29
        [self setIsTouchEnabled:YES];
        
        // AULA 4 - Coloca o Parallax Bg
        [self poeBackgroundImg:@"SGallego_Rio.jpg"];

    }
    return self;
}

-(void)configuraJogo{
    _isBossOnStage = NO;
    _isSubBossOnStage = NO;
    _isSubBossDead = NO;
    _vidas = 3;
    _score = 0;
    forcaInimigo = 0;

    //Verifica se é um telefone para diminuir o tamanho dos objetos pela metade
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        factorScale = 0.5;
    }
    
    CCSprite *sprite = [inimigosArray bossSprite];
    sprite.visible = NO;

}

// Inimigo
// AULA 2 - Passo 11
- (void)atualizaInimigo:(ccTime)dt {
    if(!_isGameActive) return;
    
    double curTime = CACurrentMediaTime();

    if (curTime > proximoInimigoCria) {
        
        float randSecs = valorRandEntre(0.20, 1.0);
        proximoInimigoCria = randSecs + curTime;
        
        // Versao 2, com Array
        
        //
        // AULA 2 - Passo 22 modifica abordagem v1 pela v2
        //
        
        //TODO Modificar score para 200
        if(_score > 5 && !_isSubBossOnStage && !_isSubBossDead){
            _isSubBossOnStage = YES;
            [self adicionaSubBoss];
        }
        
        //TODO Modificar score para 500
        if(_score > 12 && _isSubBossDead && !_isBossOnStage){
            _isBossOnStage = YES;
            [self adicionaBoss];
        }
        
        if(!_isSubBossOnStage){
            [self adicionaInimigoSimples];
        }
    }
}

-(void)adicionaInimigoSimples{
    
    CCSprite *inimigo = [inimigosArray nextSprite];
    
    float randY = valorRandEntre(0.0, winSize.height);    
    float randDuration = valorRandEntre(2.0, 10.0);
    float scale = 0;
    int forca = 0;
    int tag = 0;
    
    // Definir tamanho entre um dos 3 tamanhos aleatórios
    CGPoint position = ccp(winSize.width+inimigo.contentSize.width/2, randY);
    int randNum = arc4random() % 3;
    
    switch (randNum) {
        case 0:
            scale = 0.25 * factorScale;
            forca=1;
            break;
        case 1:
            scale = 0.5 * factorScale;
            forca = 1;
            break;
        case 2:
            scale = 1.0 * factorScale;
            forca = 2;
            break;
        default:
            break;
    }

    NSNumber * forcaPorTipoPersonagem = [inimigosArray currentItemForce];
    int intForcaPorPersonagem = [forcaPorTipoPersonagem  intValue];
    forca = randNum + intForcaPorPersonagem;
    tag = 10+randNum;
    
    CCSequence *sequenciaInimigo = [CCSequence actions:
                        [CCMoveBy actionWithDuration:randDuration
                                            position:ccp(-winSize.width-inimigo.contentSize.width, 0)],
                        [CCCallFuncN actionWithTarget:self                                                        selector:@selector(invisNode:)], nil];
    
    [self criaInimigo:inimigo scale:scale forca:forca tag:tag position:position sequenciaInimigo:sequenciaInimigo];
    
}

-(void)adicionaSubBoss{
    CCSprite *inimigo = [inimigosArray subBossSprite];
    [self adicionaGenericBoss:inimigo scale: 2.5 * factorScale forca:30 tag:14];
}

-(void)adicionaBoss{
    CCSprite *inimigo = [inimigosArray bossSprite];
    [self adicionaGenericBoss:inimigo scale: 5 * factorScale forca:60 tag:15];
}

-(void)adicionaGenericBoss:(CCSprite*)inimigo scale:(float)scale forca:(int)forca tag:(int)tag{
    
    _boss = inimigo;    
    
    CCMoveBy *movimentoEntrada = [CCMoveBy
                                  actionWithDuration:2
                                  position:ccp(-winSize.width/4, 0)];
    CCCallFuncN *chamaFuncaoMovimento = [CCCallFuncN
                                         actionWithTarget:self
                                         selector:@selector(movimentoBoss:)];
    _moveUp = true;

    float widthInimigo = inimigo.contentSize.width;
    
    CGPoint position = ccp(winSize.width+widthInimigo/2, winSize.height/2);
    
    CCSequence *sequenciaInimigo = [CCSequence actions: movimentoEntrada, chamaFuncaoMovimento, nil];
    
    [self criaInimigo:inimigo scale:scale forca:forca tag:tag position:position sequenciaInimigo:sequenciaInimigo];
    
}

-(void)criaInimigo:(CCSprite*)inimigo scale:(float)scale forca:(int)forca tag:(int)tag position:(CGPoint)position sequenciaInimigo:(CCSequence*)sequenciaInimigo {
    
    inimigo.scale = scale;
    forcaInimigo += forca;
    [inimigo setTag:tag];

    inimigo.position = position;    
    
    [inimigo stopAllActions];
    inimigo.visible = YES;
    [inimigo runAction: sequenciaInimigo];
}

//Movimento de para cima e para baixo do Boss
-(void)movimentoBoss:(CCNode *)sender{
    
    int direction = winSize.height-_boss.contentSize.height;
    if(!_moveUp){
        direction = 0+_boss.contentSize.height;
    }
    CCMoveTo *movimento = [CCMoveTo
                                 actionWithDuration:2
                                 position:ccp(winSize.width*.75, direction)];
    [_boss runAction:[CCSequence actions: movimento, [CCCallFuncN actionWithTarget:self                                                        selector:@selector(movimentoBoss:)], nil]];
    _moveUp = !_moveUp;
    
}

// Acelerometro
// AULA 2 - Passo 3
- (void)atualizaPosicaoHeroi:(ccTime)dt {
    float maxY = winSize.height - heroi.contentSize.height/2;
    float minY = heroi.contentSize.height/2;
    float newY = heroi.position.y + (heroiPontosPorSegY * dt);
    newY = MIN(MAX(newY, minY), maxY);
    heroi.position = ccp(heroi.position.x, newY);
}


// AULA 2 - Passo 31, um sistema simples e tosco de colisão...
// temos que melhorar isso depois... precisamos declarar antes do update
- (void)atualizaColisoes:(ccTime)dt {
    if(!_isGameActive) return;
    // 1. bala vs inimigo
    for (CCSprite *bala in balaArray.array) {
        if (!bala.visible) continue;
        for (CCSprite *inimigo in inimigosArray.array) {
            if (!inimigo.visible) continue;
            if (CGRectIntersectsRect(inimigo.boundingBox, bala.boundingBox)) {
               
                matouInimigo = TRUE;
                [[SimpleAudioEngine sharedEngine] playEffect:@"morrendo.mp3"
                                                   pitch:1.0f 
                                                   pan:0.0f 
                                                gain:3.25f];
              
                // Inimigos pequenos valem menos resistencia
                switch ([inimigo tag]) {
                    case 10:
                        forcaInimigo-=3;
                        break;
                    case 11:
                        forcaInimigo-=2;
                        break;
                    default:
                        forcaInimigo--;
                        break;
                }
                
                // Não permite inimigo acumular MUITA fraqueza senao o game fica chato
                if (forcaInimigo < -11)
                    forcaInimigo = 0;
                
                // Ponto somente pra inimigos sem vida.
                if (forcaInimigo < 1) {
                    inimigo.visible = NO;
                    
                    switch([inimigo tag]){
                        //SubBoss
                        case 14:
                            _score+=5;
                            _isSubBossOnStage = NO;
                            _isSubBossDead = YES;
                            [self addParticle:@"fire.png" startSize:5.0f endSize:40.0f speed:100 lifeVar:0.5f duration:3.0f position:inimigo.position z:9 tag:particulaAcertouInimigo];
                            [[SimpleAudioEngine sharedEngine] playEffect:@"morrendo.mp3"
                                                                   pitch:1.0f
                                                                     pan:0.0f
                                                                    gain:5.25f];
                            break;
                        //Boss
                        case 15:
                            _score+=15;
                            _isBossOnStage = NO;
                            [self trocaBackgroundImg:@"SGallego_Malibu.jpg"];
                            [self exibeLabelLevel:2];
                            [self addParticle:@"fire.png" startSize:5.0f endSize:40.0f speed:100 lifeVar:0.5f duration:3.0f position:inimigo.position z:9 tag:particulaAcertouInimigo];
                            [[SimpleAudioEngine sharedEngine] playEffect:@"morrendo.mp3"
                                                                   pitch:1.0f
                                                                     pan:0.0f
                                                                    gain:5.25f];
                            break;
                        //Inimigo Comum
                        default:
                            _score++;
                            break;
                    }
                    
                }
                    bala.visible = NO;
                
                NSLog(@"Forca Inimigo: %d ",forcaInimigo);
                
                    //_score++;
                    _scoreLabel.string = [NSString stringWithFormat:@"Score: %d", _score];
                
                    // Vamos mostrar a resistencia do inimigo
                    _forcaInimigoLabel.string = [NSString stringWithFormat:@"Resist: %d", forcaInimigo];
                
                    [self addParticle:@"fire.png" startSize:5.0f endSize:10.0f speed:100 lifeVar:0.5f duration:1.5f position:inimigo.position z:10 tag:particulaAcertouInimigo];
                
                    break;
            } else
                    matouInimigo = TRUE;
        }
    }
    
    // 2. Jogador vs inimigo
    for (CCSprite *inimigo in inimigosArray.array) {
        if (!inimigo.visible) continue;
        if (CGRectIntersectsRect(inimigo.boundingBox, heroi.boundingBox))
        {
//            heroi.visible = NO;
            _vidas--;
            inimigo.visible = NO;
            
            CCParticleSystem *particula = [CCParticleSun node];
            particula.texture = [[CCTextureCache sharedTextureCache] addImage:@"fire.png"];
            
            particula.startSize = 10.0f;
            particula.endSize = 40.0f;
            particula.speed = 200;
            particula.lifeVar = 0.5f;
            particula.duration = 0.5f;
            
            particula.position = heroi.position;
            
            [self addChild:particula z:10 tag:particulaAcertouHeroi];
            
            //[self addParticle:@"fire.png" startSize:10.0f endSize:40.0f speed:200 lifeVar:0.5f duration:0.5f position:heroi.position z:10 tag:particulaAcertouHeroi];
            
            _vidasLabel.string = [NSString stringWithFormat:@"Vidas: %d", _vidas];
            if(_vidas < 1)
            {
                _tituloGameOver.scale = 2 * factorScale;
                clickRestart.scale = 1;
                _isGameActive = false;
                heroi.visible = false;
                
//                _vidas = 3;
//                _vidasLabel.string = [NSString stringWithFormat:@"Vidas: %d", _vidas];
                
                return;
            }
            break;
        }
    }
    
}

-(void)addParticle:(NSString*)image startSize:(float)startSize endSize:(float)endSize speed:(float)speed lifeVar:(float)lifeVar duration:(float)duration position:(CGPoint)position z:(int)z tag:(enum MinhasParticulas)tag{
    
    CCParticleSystem *particula = [CCParticleFire node];
    
    particula.texture = [[CCTextureCache sharedTextureCache] addImage:image];
    
    particula.startSize = startSize;
    particula.endSize = endSize;
    particula.speed = speed;
    particula.lifeVar = lifeVar;
    particula.duration = duration;
    
    particula.position = position;
    
    [self addChild:particula z:z tag:tag];
    
}

// AULA 4 atualiza Bg, pra fazer o Parallax Node mover...
-(void) atualizaBg:(ccTime)dt {
    // diminui a velocidade do background
    CGPoint bgVelocidade = ccp(-200,0);
    _backgroundGame.position = ccpAdd(_backgroundGame.position, ccpMult(bgVelocidade,dt));
    
    NSArray *objetos = [NSArray arrayWithObjects:_obj2, nil];
    
    
    //NSArray *objetos = [NSArray arrayWithObjects:_objeto2, nil];
    for (CCSprite *objeto in objetos) {
        if ([_backgroundGame convertToWorldSpace:objeto.position].x < -objeto.contentSize.width*objeto.scale) {
            [_backgroundGame incrementOffset:
             ccp( ((winSize.width / (objeto.contentSize.width*objeto.scale))+2)*objeto.contentSize.width  * objeto.scale,0) forChild:objeto];
        }
    }
    NSArray *backgrounds = [NSArray arrayWithObjects:_obj1, nil];
    for (CCSprite *background in backgrounds) {
        
        if ([_backgroundGame convertToWorldSpace:background.position].x <
            -(background.contentSize.width*background.scaleX/2 - winSize.width) ) {
            [_backgroundGame incrementOffset:ccp(2500,0) forChild:background];
        }
        
    }
}

// Acelerometro
// AULA 2 - Passo 4
// Essa funcao tem que se chamar update porque é com esse nome
// que o Cocos2D chama ao agendar com secheduleUpdate no init
- (void)update:(ccTime)dt {
    [self atualizaPosicaoHeroi:dt];
    
    // AULA 2 - Passo 12
    [self atualizaInimigo:dt];
    
    // AULA 2 - Passo 32
    [self atualizaColisoes:dt];
    
    // AULA 4 - chama a funcao que atualiza o bg
    // redefinindo a POSICAO do parallax node
    [self atualizaBg:dt];
}

// Acelerometro
// AULA 2 - Passo 5
- (void)accelerometer:(UIAccelerometer *)accelerometer
        didAccelerate:(UIAcceleration *)acceleration {
    
#define kFatorFiltro 0.8
    static UIAccelerationValue rolaX = 0, rolaY = 0, rolaZ = 0;
    
    rolaX = (acceleration.x * kFatorFiltro) + 
    (rolaX * (1.0 - kFatorFiltro));    
    rolaY = (acceleration.y * kFatorFiltro) + 
    (rolaY * (1.0 - kFatorFiltro));    
    rolaZ = (acceleration.z * kFatorFiltro) + 
    (rolaZ * (1.0 - kFatorFiltro));
    
    float aceleraX = rolaX;
    float aceleraY = rolaY;
    float aceleraZ = rolaZ;
    
#define kRestAccelX 0.6
#define kShipMaxPointsPerSec (winSize.height*0.5)
#define kMaxDiffX 0.2
    
    float accelDiffX = kRestAccelX - ABS(aceleraX);
    float accelFracaoX = accelDiffX / kMaxDiffX;
    float pontosPorSegX = kShipMaxPointsPerSec * accelFracaoX;
    
    /*
     NSLog(@"acceleration.x: %f, accelX: %f, accelY: %f, accelZ: %f, "
          "rollingX: %f, accelDiffX: %f, accelFractionX: %f, pointsPerSecX: %f",
          acceleration.x, aceleraX, aceleraY, aceleraZ, 
          rolaX, accelDiffX, accelFracaoX, pontosPorSegX);
     */
    
    heroiPontosPorSegY = pontosPorSegX;
}

// Faz o sprite (node) ficar invisivel
// AULA 2 - Passo 24 cria a funcaozinha que torna qq coisa invisivel
- (void)invisNode:(CCNode *)sender {
    sender.visible = FALSE;
    if(_isGameActive)
    {
//        NSLog(@"Sender: %@",sender);
//        NSLog(@"Sender Tag: %d",[sender tag]);
//        
        // Se o inimigo passou e nao morreu, perde 2 pontos
        // Como usamos o mesmo invisNode pra balas e inimigos temos que saber
        // se perdemos bala ou inimigo na tela.. marcamos bala com tag:10
        if ((!matouInimigo) && ([sender tag] != 20) ) {
            //_score -= 2; // muito dificil
            //_score--;
            _score++;
        }
        
        // Se deixar passar vivo, um inimigo grande, da mais resistencia a eles
        //if (!matouInimigo &&([sender tag] == 12))
            //forcaInimigo += 2;
            
        _scoreLabel.string = [NSString stringWithFormat:@"Score: %d", _score];
        _forcaInimigoLabel.string = [NSString stringWithFormat:@"Resist: %d", forcaInimigo];
    }
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
//    if([self isAccelerometerEnabled]) return;
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView: [touch view]];
    
    touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];

    if(touchLocation.x < 250)
    {
        if(heroi.position.y < touchLocation.y)
            heroiPontosPorSegY = 400;
        else
            heroiPontosPorSegY = -400;
    }
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    heroiPontosPorSegY = 0;
}

// AULA 2 - Passo 30, manda bala quando clicar na tela
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(!_isGameActive) return;
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView: [touch view]];
    
    touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    
//    NSLog(@"X: %f, Y: %f", touchLocation.x, touchLocation.y);
    
    if(!heroi) return;
    if((!heroi) || (touchLocation.x < 128 * factorScale)) return;
    
    
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"porrada.mp3"
                                           pitch:1.0f 
                                             pan:0.0f
                                            gain:3.25f ];
    CCSprite *bala = [balaArray nextSprite];
    [bala stopAllActions];
    bala.visible = YES;
    bala.position = ccpAdd(heroi.position,
                                ccp(bala.contentSize.width/2, 0));
    
    [bala setTag:20]; // marcando bala com tag 20 pra identificar no sender
    bala.scaleY = 1.0 * factorScale;
    bala.scaleX = 1.0 * factorScale;
    [bala runAction:
     [CCSequence actions:
      [CCMoveBy actionWithDuration:0.5
                          position:ccp(winSize.width, 0)],
      [CCCallFuncN actionWithTarget:self
                           selector:@selector(invisNode:)],
      nil]];
}

-(void)jogarBestie:(id)sender
{
    playerGame = 0;
}

-(void)jogarHexley:(id)sender
{
    playerGame = 1;
}

// Desaloca memoria
// AULA 2 - Passo 25 dealloc de super e o que mais for preciso
- (void)dealloc {
    // Array de inimigos
    [inimigosArray release];
    
    // Metodo super recomendado Apple
    [super dealloc];
    
    // AULA 2 - Passo 28
    [balaArray release];
}

@end