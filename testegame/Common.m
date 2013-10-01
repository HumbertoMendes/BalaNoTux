//
//  Common.m
//  testegame
//
//  Created by Patrick Tracanelli on 28/11/11.
//  Copyright 2011 FreeBSD Brasil LTDA. All rights reserved.
//

// AULA 2 - Passo 8
#import "Common.h"


// Inimigo
// AULA 2 - Passo 8
float valorRandEntre(float low, float high) {
    return (((float) arc4random() / 0xFFFFFFFFu)
            * (high - low)) + low;
}
