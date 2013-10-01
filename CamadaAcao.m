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

+ (id)scene {
    CCScene *cena = [CCScene node];
    CamadaAcao *camada = [CamadaAcao node]; 
    [cena addChild:camada]; 
    return cena;
} 

// SOM
- (void)poeSom { 
    //[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"patrick_soundtrack.mp3" loop:YES]; 
    
    // preload dos proximos sons
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"som_exemplo.mp3"];
}

// Particula Estrela
- (void)poeEstrela {
    CGSize tamanhoTela = [CCDirector sharedDirector].winSize;
    NSArray *estrelinhas = [NSArray arrayWithObjects:
                           @"Stars1.plist", 
                           @"Stars2.plist",
                           @"Stars3.plist", nil];
    for(NSString *estrela in estrelinhas) {
        CCParticleSystemQuad *efeitoEstrela = [CCParticleSystemQuad
                                             particleWithFile:estrela];
        efeitoEstrela.position = ccp(tamanhoTela.width*1.5, tamanhoTela.height/2);
        efeitoEstrela.posVar = ccp(efeitoEstrela.posVar.x, (tamanhoTela.height/2) * 1.5);
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
    chovechuva.startSize = 10.0f;
    
    [self addChild: chovechuva z:10];

}

// Desliga Inicio e demais titulos
-(void)removeNode:(CCNode *)sender {
    [sender removeFromParentAndCleanup:YES];
}

// Lança e inicia (spawn) o protagonista adicionando um sprite dele no jogo
- (void)poeProtagonista {
    CGSize tamanhoJanela = [CCDirector sharedDirector].winSize;
    heroi = [CCSprite spriteWithSpriteFrameName:@"beastie-down40.png"];
    heroi.position = ccp(-heroi.contentSize.width/2,
                        tamanhoJanela.height * 0.5);
    [batchNode addChild:heroi z:1 tag:heroiTag];
    [heroi runAction:
     [CCSequence actions:
      [CCEaseOut actionWithAction:
       [CCMoveBy actionWithDuration:0.5
                           position:ccp(heroi.contentSize.width/2 + tamanhoJanela.width*0.3,
                                        0)]
                             rate:4.0],
      [CCEaseInOut actionWithAction:
       [CCMoveBy actionWithDuration:0.5
                           position:ccp(-tamanhoJanela.width*0.2, 0)]
                               rate:4.0],
      nil]];
  
    // Anima o protagonista
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

-(void)apertouRestart:(id)sender {
    NSLog(@"Clicou Restart: %d", _vidas);
    
    // Sai da funcao se nao estiver morto.
    if (_vidas >0 ) return;
    
    _isGameActive = TRUE;
    _vidas = 3;
    heroi.visible = TRUE;
    _score = 0;
    forcaInimigo = 0;
    _tituloGameOver.scale = 0;
    _vidasLabel.string = [NSString stringWithFormat:@"Vidas: %d", _vidas];
}

// Inicio
- (void)apertouInicio:(id)sender {
    [[SimpleAudioEngine sharedEngine] playEffect:@"powerup.caf"];
    NSArray * nodes = [NSArray arrayWithObjects:_titulo1, _titulo2, clickInicio,
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
    _vidasLabel.scale = 1.5;

    _score = 0;
    _scoreLabel.string = [NSString stringWithFormat:@"Score: %d", _score];
    _scoreLabel.scale = 1.5;
    
    _forcaInimigoLabel.string = [NSString stringWithFormat:@"Resist: %d", forcaInimigo];
    _forcaInimigoLabel.scale = 1.5;

    _isGameActive = true;
}

- (void)poeTitulo {
    
    CGSize tamanhoJanela = [CCDirector sharedDirector].winSize;
    
    NSString *fontName = @"fonteCasual.fnt"; 
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        fontName = @"fonteCasual-hd.fnt";
    }
    
    _titulo1 = [CCLabelBMFont labelWithString:@"IDS Tecnologia" fntFile:fontName];
    // efeitos
    _titulo1.scale = 0;
    
    //_titulo1.scale = 0.5; 
    _titulo1.position = ccp(tamanhoJanela.width/2, tamanhoJanela.height * 0.8); 
    [self addChild:_titulo1 z:100];
    
    // efeitos
    [_titulo1 runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:1.0],
      [CCScaleTo actionWithDuration:1.0 scale:2.5],
      nil]];
    
    _titulo2 = [CCLabelBMFont labelWithString:@"Bala no TuX!" fntFile:fontName];
    // efeitos
    _titulo2.scale = 0;

    //_titulo2.scale = 1.25; 
    _titulo2.position = ccp(tamanhoJanela.width/2, tamanhoJanela.height * 0.6); 
    [self addChild:_titulo2 z:100];
    
    
    
    // efeitos
    [_titulo2 runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:1.0],
      [CCScaleTo actionWithDuration:1.0 scale:3.5],
      nil]];
    
    // titulo Inicio
    CCLabelBMFont *playLabel = [CCLabelBMFont labelWithString:@"Iniciar" fntFile:fontName];
    clickInicio = [CCMenuItemLabel itemWithLabel:playLabel 
                                       target:self
                                     selector:@selector(apertouInicio:)];
    [clickInicio setScale:0];
    
    [clickInicio setPosition:ccp(tamanhoJanela.width/2, tamanhoJanela.height * 0.3)];

    CCMenu *menu = [CCMenu menuWithItems:clickInicio, nil];
    [menu setPosition:CGPointZero];
    //menu.position = CGPointZero;
    [self addChild:menu];
    
    [clickInicio runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:2.0],
      [CCEaseOut actionWithAction:
       [CCScaleTo actionWithDuration:0.5 scale:2.5] rate:4.0],
      nil]];
    
    
    // Vidas
    _vidasLabel = [CCLabelBMFont labelWithString:@"Vidas: x" fntFile:fontName];
    _vidasLabel.scale = 0;
    _vidasLabel.position = ccp(tamanhoJanela.width/8, tamanhoJanela.height * 0.95);
    [self addChild:_vidasLabel z:100];

    // Score
    _scoreLabel = [CCLabelBMFont labelWithString:@"Score: x" fntFile:fontName];
    _scoreLabel.scale = 0;
    _scoreLabel.position = ccp(tamanhoJanela.width/8, tamanhoJanela.height * 0.05);
    [self addChild:_scoreLabel z:100];
    
    // Força do Inimigo
    _forcaInimigoLabel = [CCLabelBMFont labelWithString:@"Resist: x" fntFile:fontName];
    _forcaInimigoLabel.scale = 0;
    _forcaInimigoLabel.position = ccp(tamanhoJanela.width*0.85, tamanhoJanela.height * 0.05);
    [self addChild:_forcaInimigoLabel z:100];

    // Game Over
    _isGameActive = false;
    _tituloGameOver = [CCLabelBMFont labelWithString:@"Restart" fntFile:fontName];
    _tituloGameOver.scale = 0; // Game Over fica invisivel
        
    CCMenuItemLabel *itemRestart;
    itemRestart = [CCMenuItemLabel itemWithLabel:_tituloGameOver
                        target:self selector:@selector(apertouRestart:)];
    
    
    [itemRestart setPosition:ccp(tamanhoJanela.width, tamanhoJanela.height/2)];
    
    CGSize NovoTamanho = CGSizeMake(tamanhoJanela.width, 100);
    // Vamos ;tentar corrigir o tamanho da area do click do menu...
    [itemRestart setContentSize:NovoTamanho];
    
    CCMenu *menuOver = [CCMenu menuWithItems:itemRestart, nil];
    [menuOver setPosition:CGPointZero];
    [self addChild:menuOver];
    
    /*[clickRestart runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:2.0],
      [CCEaseOut actionWithAction:
       [CCScaleTo actionWithDuration:0.5 scale:2.5] rate:4.0],
      nil]];*/


}

- (void)colocaBatchNode {
    NSString *spritesImg = @"spriteSheet.png";
    NSString *spritesPlist = @"spriteSheet.plist";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        spritesImg = @"spriteSheet.png";
        spritesPlist = @"spriteSheet.plist";
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
                                           spriteFrameName:@"flyingtux40.png" 
                                                 batchNode:batchNode];
    // Aula 2 - Passo 27
    balaArray = [[SpriteArray alloc] initWithCapacity:5
                                       spriteFrameName:@"logo.png" 
                                             batchNode:batchNode];
}

// AULA 4
- (void)poeBackground {
    _vidas = 1; // Quando apertar Inicio ou Restart tera 3 vidas
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    // Passo 1, criamos o CCParallaxNode
    _backgroundGame = [CCParallaxNode node];
    [self addChild:_backgroundGame z:-2];
    
    // Passo2, vamos adicionar os sprites obj1 e 2 no 
    // parallax node...
    // Primeiro vamos testar se eh iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // Colocar nos objets parallax variasveis com arquivo
        // imagem, como eh iPad, HD
        _obj1 = [CCSprite spriteWithFile:@"SGallego_Rio.jpg"];
        _obj2 = [CCSprite spriteWithFile:@"nuvem.gif"];
        
        _obj1.scaleX = 4.0;
        _obj1.scaleY = 2.0;
        
    } else {
        _obj1 = [CCSprite spriteWithFile:@"SGallego_Rio.jpg"];
        _obj2 = [CCSprite spriteWithFile:@"nuvem.gif"];
    
    }
    
    // 3 passo determinar a velocidade relativa do bg
    CGPoint velocidadeObj = ccp(0.1,0.1);
    CGPoint velocidadeBg = ccp(0.05,0.05);
    
    // Passo 4 adiciona os objetos filho ao CC PArallax Node
    [ _backgroundGame addChild:_obj2 z:0 parallaxRatio:velocidadeObj positionOffset:ccp(winSize.width,winSize.height * 0.9)];
    
    // E agora mesma coisa no objeto1
    [_backgroundGame addChild:_obj1 z:-1 parallaxRatio:velocidadeBg positionOffset:ccp(0,winSize.height/2)];
    
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
        [self poeBackground];

    }
    return self;
}

-(void)configuraJogo{
    _isBossOnStage = NO;
}

// Inimigo
// AULA 2 - Passo 11
- (void)atualizaInimigo:(ccTime)dt {
    if(!_isGameActive) return;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;    
    double curTime = CACurrentMediaTime();

    
    if (curTime > proximoInimigoCria) {
        
        float randSecs = valorRandEntre(0.20, 1.0);
        proximoInimigoCria = randSecs + curTime;
        
        float randY = valorRandEntre(0.0, winSize.height);
        
        float randDuration = valorRandEntre(2.0, 10.0);
        
        // Versao 2, com Array
        
        //
        // AULA 2 - Passo 22 modifica abordagem v1 pela v2
        //
        
        // Versao 1, sem Array
        //CCSprite *inimigo = [CCSprite spriteWithSpriteFrameName:@"flyingtux40.png"];
        //[batchNode addChild:inimigo];
        
        CCSequence *sequenciaInimigo;
        CCSprite *inimigo;
        
        if(_score > -3 && !_isBossOnStage){
            inimigo = [inimigosArray bossSprite];
            
            inimigo.scale = 2.5;
            forcaInimigo += 5;
            [inimigo setTag:14];
            _isBossOnStage = YES;
            _boss = inimigo;
            
            float widthInimigo = inimigo.contentSize.width;
            
            inimigo.position = ccp(winSize.width+widthInimigo/2, winSize.height/2);
            
            
            CCMoveBy *movimentoEntrada = [CCMoveBy
                                          actionWithDuration:2
                                          position:ccp(-winSize.width/4, 0)];
            CCCallFuncN *chamaFuncaoMovimento = [CCCallFuncN
                                                 actionWithTarget:self
                                                 selector:@selector(movimentoBoss:)];
            _moveUp = true;
            sequenciaInimigo = [CCSequence actions: movimentoEntrada, chamaFuncaoMovimento, nil];
            
        }else{
            inimigo = [inimigosArray nextSprite];
            
            // Definir tamanho entre um dos 3 tamanhos aleatórios
            inimigo.position = ccp(winSize.width+inimigo.contentSize.width/2, randY);
            int randNum = arc4random() % 3;
            if (randNum == 0) {
                inimigo.scale = 0.25;
                forcaInimigo++;
                [inimigo setTag:10];
            }
            else if (randNum == 1)
            {
                inimigo.scale = 0.5;
                forcaInimigo++;
                [inimigo setTag:11];

            }
            else
            {
                forcaInimigo += 2; // não matar inimigo grande eh vacilo e os outros ficam mais resistentes
                inimigo.scale = 1.0;
                [inimigo setTag:12]; // tag 12 inimigo grande
            }
            sequenciaInimigo = [CCSequence actions:
                                    [CCMoveBy actionWithDuration:randDuration
                                        position:ccp(-winSize.width-inimigo.contentSize.width, 0)],
                                    [CCCallFuncN actionWithTarget:self                                                        selector:@selector(invisNode:)], nil];
        }
        
        [inimigo stopAllActions];
        inimigo.visible = YES;
        // Movê-lo para fora da tela a esquerda, e quando feito chamar removeNode
        [inimigo runAction: sequenciaInimigo];
    }
}
//Movimento de para cima e para baixo do Boss
-(void)movimentoBoss:(CCNode *)sender{
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
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
    CGSize winSize = [CCDirector sharedDirector].winSize;
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
                    _score++;
                }
                    bala.visible = NO;
                
                NSLog(@"Forca Inimigo: %d ",forcaInimigo);
                
                    //_score++;
                    _scoreLabel.string = [NSString stringWithFormat:@"Score: %d", _score];
                
                    // Vamos mostrar a resistencia do inimigo
                    _forcaInimigoLabel.string = [NSString stringWithFormat:@"Resist: %d", forcaInimigo];
                
                    CCParticleSystem *particula = [CCParticleFire node];
                    particula.texture = [[CCTextureCache sharedTextureCache] addImage:@"fire.png"];
                    
                    particula.startSize = 5.0f;
                    particula.endSize = 10.0f;
                    particula.speed = 100;
                    particula.lifeVar = 0.5f;
                    particula.duration = 1.5f;
                    
                    particula.position = inimigo.position;
                    
                    [self addChild:particula z:10 tag:particulaAcertouInimigo];
                    
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
            
            _vidasLabel.string = [NSString stringWithFormat:@"Vidas: %d", _vidas];
            if(_vidas < 1)
            {
                _tituloGameOver.scale = 2;
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

// AULA 4 atualiza Bg, pra fazer o Parallax Node mover...
-(void) atualizaBg:(ccTime)dt {
    // diminui a velocidade do background
    CGPoint bgVelocidade = ccp(-200,0);
    _backgroundGame.position = ccpAdd(_backgroundGame.position, ccpMult(bgVelocidade,dt));
    
    NSArray *objetos = [NSArray arrayWithObjects:_obj2, nil];
    
    for (CCSprite *objeto in objetos) {
        if ([_backgroundGame convertToWorldSpace:objeto.position].x < -
            objeto.contentSize.width*self.scale) {
                [_backgroundGame
                 incrementOffset:ccp(objeto.contentSize.width* objeto.scale,0)
                    forChild:objeto];
        }
    }
    
    NSArray *backgrounds = [NSArray arrayWithObjects:_obj1, nil];for (CCSprite *background in backgrounds) {
        if ([_backgroundGame convertToWorldSpace:background.position].x < - background.contentSize.width*self.scale) {
            [_backgroundGame incrementOffset:ccp(1000,0) forChild:background];
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
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
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
    
    CGSize winSize = [CCDirector sharedDirector].winSize;

    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView: [touch view]];
    
    touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    
    //NSLog(@"X: %f, Y: %f", touchLocation.x, touchLocation.y);
    
    if(!heroi) return;
    if((!heroi) || (touchLocation.x < 128)) return;
    
    
    
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
    [bala runAction:
     [CCSequence actions:
      [CCMoveBy actionWithDuration:0.5
                          position:ccp(winSize.width, 0)],
      [CCCallFuncN actionWithTarget:self
                           selector:@selector(invisNode:)],
      nil]];
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