/*
 * This file is part of Gorillas.
 *
 *  Gorillas is open software: you can use or modify it under the
 *  terms of the Java Research License or optionally a more
 *  permissive Commercial License.
 *
 *  Gorillas is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 *  You should have received a copy of the Java Research License
 *  along with Gorillas in the file named 'COPYING'.
 *  If not, see <http://stuff.lhunath.com/COPYING>.
 */

//
//  StatisticsLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "StatisticsLayer.h"
#import "GorillasAppDelegate.h"
#import "BuildingsLayer.h"
#define gBarSize 25


@implementation StatisticsLayer


-(id) init {
    
    if(!(self = [super init]))
        return self;
    
    scoreTowers = [[NSMutableArray alloc] initWithCapacity:20];
    
    // Back.
    [MenuItemFont setFontSize:[[GorillasConfig get] largeFontSize]];
    MenuItem *back     = [MenuItemFont itemFromString:@"   <   "
                                               target: self
                                             selector: @selector(back:)];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    
    menu = [[Menu menuWithItems:back, nil] retain];
    [menu setPosition:ccp([[GorillasConfig get] fontSize], [[GorillasConfig get] fontSize])];
    [menu alignItemsHorizontally];
    [self addChild:menu];
    
    return self;
}


-(void) onEnter {
    
    [self reset];

    [super onEnter];
}


-(void) reset {
    
    // Get the top scores.
    NSDictionary *topScores = [[GorillasConfig get] topScoreHistory];
    NSMutableArray *dates = [[NSMutableArray alloc] initWithCapacity:[topScores count]];
    NSMutableArray *scores = [[NSMutableArray alloc] initWithCapacity:[topScores count]];
    
    NSString **tDates = malloc(sizeof(NSString *) * [topScores count]);
    NSNumber **tScores = malloc(sizeof(NSNumber *) * [topScores count]);
    [topScores getObjects:tScores andKeys:tDates];
    
    // Convert their keys from NSStrings into NSDates for sorting.
    int topScore = 0;
    NSDateFormatter *defaultDateFormatter = [[NSDateFormatter alloc] init];
    [defaultDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
    for(NSUInteger i = 0; i < [topScores count]; ++i) {
        [dates addObject:[defaultDateFormatter dateFromString:tDates[i]]];
        [scores addObject:tScores[i]];
        if(topScore < [tScores[i] intValue])
            topScore = [tScores[i] intValue];
    }
    [defaultDateFormatter release];
    free(tDates);
    free(tScores);
    
    // Top score label.
    Label *topScoreLabel = [[Label alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"entries.score.top", @"Top Score: %04d"), topScore]
                                              dimensions:CGSizeMake(200, [[GorillasConfig get] fontSize])
                                               alignment:UITextAlignmentCenter
                                                fontName:[[GorillasConfig get] fixedFontName]
                                                fontSize:[[GorillasConfig get] smallFontSize]];
    [topScoreLabel setPosition:ccp(contentSize.width / 2, contentSize.height - padding + [[GorillasConfig get] smallFontSize])];
    [self addChild:topScoreLabel];
    [topScoreLabel release];
    
    // Iterate over sorted data and add them as Labels.
    int x = padding;
    
    // Formatter for our score dates.
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d"];
    
    int i = 0;
    NSDictionary *history = [[NSDictionary alloc] initWithObjects:scores forKeys:dates];
    [dates release];
    [scores release];
    dates = nil;
    scores = nil;
    
    NSEnumerator *datesEnumerator = [[[history allKeys] sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator];
    for(NSDate *date in [datesEnumerator allObjects]) {
        
        // Height ratio of score tower.
        //  - Adjust ratio for top and bottom tower padding.
        //  - Adjust ratio to undo theme's max building height.
        int score = [(NSNumber *) [history objectForKey:date] floatValue];
        float scoreRatio = ((float) score / topScore);
        scoreRatio *= ((contentSize.height - padding * 2) / contentSize.height);
        scoreRatio /= [[GorillasConfig get] buildingMax];
        if(!score)
            scoreRatio = 0.001f;
        
        // Score tower.
        BuildingsLayer *scoreTower = [[BuildingsLayer alloc] initWithWidth:gBarSize
                                                             heightRatio:scoreRatio];
        
        // Score label.
        Label *scoreLabel = [[Label alloc] initWithString:[NSString stringWithFormat:@"%d", score]
                                               dimensions:CGSizeMake(gBarSize * 2, [[GorillasConfig get] smallFontSize] / 2)
                                                alignment:UITextAlignmentCenter
                                                 fontName:[[GorillasConfig get] fixedFontName]
                                                 fontSize:[[GorillasConfig get] smallFontSize] / 2];
        [scoreLabel setPosition:ccp([scoreTower contentSize].width / 2,
                                    [scoreTower contentSize].height + [scoreLabel contentSize].height)];
        
        // Score's date label.
        NSString *dateString = [dateFormatter stringFromDate:date];
        Label *dateLabel = [[Label alloc] initWithString:appendOrdinalPrefix([dateString intValue], dateString)
                                              dimensions:CGSizeMake(gBarSize * 2, [[GorillasConfig get] smallFontSize] / 2)
                                               alignment:UITextAlignmentCenter
                                                fontName:[[GorillasConfig get] fixedFontName]
                                                fontSize:[[GorillasConfig get] smallFontSize] / 2];
        [dateLabel setPosition:ccp([scoreTower contentSize].width / 2,
                                   -[dateLabel contentSize].height)];
        
        [scoreTower runAction:[Sequence actions:
                               [Sequence actionWithDuration:0.1f * i],
                               [MoveTo actionWithDuration:[[GorillasConfig get] transitionDuration]
                                                 position:ccp(x, padding)],
                               nil]];
        [scoreLabel runAction:[Sequence actions:
                               [Sequence actionWithDuration:0.1f * i],
                               [FadeIn actionWithDuration:[[GorillasConfig get] transitionDuration]],
                               nil]];
        [dateLabel runAction:[Sequence actions:
                              [Sequence actionWithDuration:0.1f * i],
                              [FadeIn actionWithDuration:[[GorillasConfig get] transitionDuration]],
                              nil]];
        
        [scoreTower setPosition:ccp(x, -[scoreTower contentSize].height - [scoreLabel contentSize].height)];
        [scoreTower addChild:scoreLabel];
        [scoreTower addChild:dateLabel];
        [scoreTowers addObject:scoreTower];
        [self addChild:scoreTower];
        
        ++i;
        x += [scoreTower contentSize].width + 1;
        [scoreTower release];
        [scoreLabel release];
        [dateLabel release];
        
        if(x >= contentSize.width - padding)
            break;
    }
    
    [dateFormatter release];
    dateFormatter = nil;
    [history release];
    history = nil;
}


-(void) dismissAsPush:(BOOL)_pushed {
    
    [super dismissAsPush:_pushed];
    
    int i = 0;
    for(BuildingsLayer *scoreTower in scoreTowers)
        [scoreTower runAction:[Sequence actions:
                               [Sequence actionWithDuration:(([[GorillasConfig get] transitionDuration] / 2) / [scoreTowers count]) * i++],
                               [MoveTo actionWithDuration:[[GorillasConfig get] transitionDuration] / 2
                                                 position:ccp([scoreTower position].x, -[scoreTower contentSize].height - [[GorillasConfig get] fontSize] * 2)],
                               nil]];
}


-(void) onExit {
    
    [super onExit];
    
    for(BuildingsLayer *scoreTower in scoreTowers)
        [self removeChild:scoreTower cleanup:YES];
    [scoreTowers removeAllObjects];
}


-(void) back: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasAppDelegate get] popLayer];
}


-(void) dealloc {
    
    [scoreTowers release];
    scoreTowers = nil;
    
    [menu release];
    menu = nil;
    
    [super dealloc];
}


@end
