//
//  HorizontalScroller.m
//  burn-ios-app
//
//  Created by Melissa Yung on 10/12/13.
//  Copyright (c) 2013 burn. All rights reserved.
//

#import "HorizontalScroller.h"
// 1
#define VIEW_PADDING 7
#define VIEW_DIMENSIONS 90
#define VIEWS_OFFSET 0

// 2
@interface HorizontalScroller () <UIScrollViewDelegate>
@end

// 3
@implementation HorizontalScroller
{
    UIScrollView *scroller;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        scroller = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        scroller.delegate = self;
        [self addSubview:scroller];
        //UILongPressGestureRecognizer *longpressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(scrollerSelected:)];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollerTapped:)];
        [scroller addGestureRecognizer:tapRecognizer];
        
        self.views = [NSMutableArray array];
    }
    return self;
}


// show the highligted image
- (void)scrollerSelected:(UILongPressGestureRecognizer*)gesture
{
    CGPoint location = [gesture locationInView:gesture.view];
    // we can't use an enumerator here, because we don't want to enumerate over ALL of the UIScrollView subviews.
    // we want to enumerate only the subviews that we added
    for (int index=0; index<[self.delegate numberOfViewsForHorizontalScroller:self]; index++)
    {
        UIView *view = scroller.subviews[index];
        if (CGRectContainsPoint(view.frame, location))
        {
            [self.delegate horizontalScroller:self selectedViewAtIndex:index];
            [scroller setContentOffset:CGPointMake(view.frame.origin.x - self.frame.size.width/2 + view.frame.size.width/2, 0) animated:YES];
            break;
        }
    }
}

- (void)scrollerTapped:(UITapGestureRecognizer*)gesture
{
    CGPoint location = [gesture locationInView:gesture.view];
    // we can't use an enumerator here, because we don't want to enumerate over ALL of the UIScrollView subviews.
    // we want to enumerate only the subviews that we added
    for (int index=0; index<[self.delegate numberOfViewsForHorizontalScroller:self]; index++)
    {
        UIView *view = scroller.subviews[index];
        if (CGRectContainsPoint(view.frame, location))
        {
            [self.delegate horizontalScroller:self clickedViewAtIndex:index];
            [scroller setContentOffset:CGPointMake(view.frame.origin.x - self.frame.size.width/2 + view.frame.size.width/2, 0) animated:YES];
            break;
        }
    }
}

- (void)reload
{
    // 1 - nothing to load if there's no delegate
    if (self.delegate == nil) return;
    
    // 2 - remove all subviews
    [scroller.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    self.views = [NSMutableArray array];
    
    // 3 - xValue is the starting point of the views inside the scroller
    CGFloat xValue = VIEWS_OFFSET;
    for (int i=0; i<[self.delegate numberOfViewsForHorizontalScroller:self]; i++)
    {
        // 4 - add a view at the right position
        xValue += VIEW_PADDING;
        UIView *view = [self.delegate horizontalScroller:self viewAtIndex:i];
        [self.views addObject:view];
        
        view.tag = 99+i;
        view.frame = CGRectMake(xValue, VIEW_PADDING, VIEW_DIMENSIONS, VIEW_DIMENSIONS);
        [scroller addSubview:view];
        xValue += VIEW_DIMENSIONS+VIEW_PADDING;
    }
    
    // 5
    [scroller setContentSize:CGSizeMake(xValue+VIEWS_OFFSET, self.frame.size.height)];
    
    // 6 - if an initial view is defined, center the scroller on it
    if ([self.delegate respondsToSelector:@selector(initialViewIndexForHorizontalScroller:)])
    {
        int initialView = [self.delegate initialViewIndexForHorizontalScroller:self];
        [scroller setContentOffset:CGPointMake(initialView*(VIEW_DIMENSIONS+(2*VIEW_PADDING)), 0) animated:YES];
    }
}

- (void)didMoveToSuperview
{
    [self reload];
}

- (void)centerCurrentView
{
    int xFinal = scroller.contentOffset.x + (VIEWS_OFFSET/2) + VIEW_PADDING;
    int viewIndex = xFinal / (VIEW_DIMENSIONS+(2*VIEW_PADDING));
    xFinal = viewIndex * (VIEW_DIMENSIONS+(2*VIEW_PADDING));
    [scroller setContentOffset:CGPointMake(xFinal,0) animated:YES];
    [self.delegate horizontalScroller:self clickedViewAtIndex:viewIndex];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self centerCurrentView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self centerCurrentView];
}


@end
