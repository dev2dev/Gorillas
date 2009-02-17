/*
 * This file is part of Gorillas.
 *
 *  Gorillas is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  Gorillas is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Gorillas in the file named 'COPYING'.
 *  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  GuideLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "GuideLayer.h"
#import "GorillasConfig.h"
#import "GorillasAppDelegate.h"


@implementation GuideLayer


-(id) init {

    if(!(self = [super init]))
        return self;

    // Guide Content.
    NSString *guideData = [NSString stringWithContentsOfFile:
                           [[NSBundle mainBundle] pathForResource:@"guide"
                                                           ofType:@"txt"]];
    NSArray *pages = [guideData componentsSeparatedByString:@"\n\n===== NEXT PAGE =====\n"];
    
    guidePages = [[NSMutableArray alloc] initWithCapacity:[pages count]];
    guideTitles = [[NSMutableArray alloc] initWithCapacity:[pages count]];
    for(NSString *guidePage in pages) {
        NSUInteger firstLineEnd = [guidePage rangeOfString:@"\n"].location;
        
        [guideTitles addObject:[guidePage substringToIndex:firstLineEnd]];
        [guidePages addObject:[guidePage substringFromIndex:firstLineEnd + 1]];
    }
    
    
    // Controls.
    [MenuItemFont setFontSize:[[GorillasConfig get] largeFontSize]];
    MenuItem *back     = [MenuItemFont itemFromString:@"   <   "
                                               target: self
                                             selector: @selector(back:)];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    
    backMenu = [[Menu menuWithItems:back, nil] retain];
    [backMenu setPosition:cpv([[GorillasConfig get] fontSize], [[GorillasConfig get] fontSize])];
    [backMenu alignItemsHorizontally];
    [self add:backMenu];
    
    [MenuItemFont setFontSize:15];
    chapterNext = [[MenuItemFont itemFromString:@"                              " target:self selector:@selector(next:)] retain];
    chapterSkip = [[MenuItemFont itemFromString:@"                              " target:self selector:@selector(skip:)] retain];
    [MenuItemFont setFontSize:26];
    chapterCurr = [[MenuItemFont itemFromString:@"                              "] retain];
    [chapterCurr setIsEnabled:NO];
    chapterMenu = [[Menu menuWithItems:chapterCurr, chapterNext, chapterSkip, nil] retain];
    [chapterMenu alignItemsHorizontally];
    [chapterMenu setPosition:cpv([chapterMenu position].x, contentSize.height - padding + 10)];
    [self add:chapterMenu];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    
    cpVect s = cpv(contentSize.width - padding, contentSize.height - [[GorillasConfig get] fontSize] - padding);
    
    CGSize winSize = [[Director sharedDirector] winSize];
    prevPageLabel = [[Label alloc] initWithString:@""
                             dimensions:CGSizeMake(s.x, s.y)
                              alignment:UITextAlignmentLeft
                               fontName:[[GorillasConfig get] fixedFontName]
                               fontSize:[[GorillasConfig get] smallFontSize]];
    [prevPageLabel setPosition:cpv(contentSize.width / 2 - winSize.width, contentSize.height / 2)];
    [prevPageLabel do:[FadeIn actionWithDuration:[[GorillasConfig get] transitionDuration]]];
    currPageLabel = [[Label alloc] initWithString:@""
                                   dimensions:CGSizeMake(s.x, s.y)
                                    alignment:UITextAlignmentLeft
                                     fontName:[[GorillasConfig get] fixedFontName]
                                     fontSize:[[GorillasConfig get] smallFontSize]];
    [currPageLabel setPosition:cpv(contentSize.width / 2, contentSize.height / 2)];
    [currPageLabel do:[FadeIn actionWithDuration:[[GorillasConfig get] transitionDuration]]];
    nextPageLabel = [[Label alloc] initWithString:@""
                                   dimensions:CGSizeMake(s.x, s.y)
                                    alignment:UITextAlignmentLeft
                                     fontName:[[GorillasConfig get] fixedFontName]
                                     fontSize:[[GorillasConfig get] smallFontSize]];
    [nextPageLabel setPosition:cpv(contentSize.width / 2 + winSize.width, contentSize.height / 2)];
    [nextPageLabel do:[FadeIn actionWithDuration:[[GorillasConfig get] transitionDuration]]];
    
    swipeLayer = [[SwipeLayer alloc] initWithTarget:self selector:@selector(swiped:)];
    [self add:swipeLayer];
    [swipeLayer add:prevPageLabel];
    [swipeLayer add:currPageLabel];
    [swipeLayer add:nextPageLabel];
    cpVect swipeAreaHalf = cpv([currPageLabel contentSize].width / 2,
                               [currPageLabel contentSize].height / 2 - [[GorillasConfig get] fontSize] / 2);
    [swipeLayer setSwipeAreaFrom:cpvsub([currPageLabel position], swipeAreaHalf)
                              to:cpvadd([currPageLabel position], swipeAreaHalf)];
    
    pageNumberLabel = [[Label alloc] initWithString:[NSString stringWithFormat:@"%d / %d", [guidePages count], [guidePages count]]
                                         dimensions:CGSizeMake(150, [[GorillasConfig get] smallFontSize])
                                          alignment:UITextAlignmentCenter
                                           fontName:[[GorillasConfig get] fontName]
                                           fontSize:[[GorillasConfig get] smallFontSize]];
    [pageNumberLabel setPosition:cpv(contentSize.width - [[GorillasConfig get] smallFontSize] * 3,
                                     padding - [[GorillasConfig get] fontSize] / 2)];
    [self add:pageNumberLabel];
    
    return self;
}


-(void) onEnter {
    
    [super onEnter];
    
    page = 0;
    [self flipPage];
    
}


-(void) swiped:(BOOL)forward {
    
    page = (page + [guidePages count] + (forward? 1: -1)) % [guidePages count];
    
    [self flipPage];
}


-(void) flipPage {
    
    NSUInteger count = [guidePages count];
    NSUInteger prevPage = (page + count - 1) % count;
    NSUInteger currPage = page;
    NSUInteger nextPage = (page + 1) % count;
    NSUInteger skipPage = (page + 2) % count;
    
    [swipeLayer setPosition:cpvzero];
    
    [pageNumberLabel setString:[NSString stringWithFormat:@"%d / %d", page + 1, count]];

    [prevPageLabel setString:[guidePages objectAtIndex:prevPage]];
    [currPageLabel setString:[guidePages objectAtIndex:currPage]];
    [nextPageLabel setString:[guidePages objectAtIndex:nextPage]];

    [chapterCurr setString:[guideTitles objectAtIndex:currPage]];
    [chapterNext setString:[guideTitles objectAtIndex:nextPage]];
    [chapterSkip setString:[guideTitles objectAtIndex:skipPage]];
}


-(void) back: (id) sender {
    
    [[GorillasAppDelegate get] clickEffect];
    [[GorillasAppDelegate get] showInformation];
}


-(void) next: (id) sender {
    
    [[GorillasAppDelegate get] clickEffect];
    page = (page + 1) % [guidePages count];
    [self flipPage];
}


-(void) skip: (id) sender {
    
    [[GorillasAppDelegate get] clickEffect];
    page = (page + 2) % [guidePages count];
    [self flipPage];
}


-(void) dealloc {
    
    [backMenu release];
    backMenu = nil;
    
    [nextMenu release];
    nextMenu = nil;
    
    [currPageLabel release];
    currPageLabel = nil;
    
    [pageNumberLabel release];
    pageNumberLabel = nil;
    
    [guideTitles release];
    guideTitles = nil;
    
    [guidePages release];
    guidePages = nil;

    [super dealloc];
}


@end
