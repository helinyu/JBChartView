//
//  JBLineChartViewController.m
//  JBChartViewDemo
//
//  Created by Terry Worona on 11/5/13.
//  Copyright (c) 2013 Jawbone. All rights reserved.
//

#import "JBLineChartViewController.h"

// Views
#import "JBLineChartView.h"
#import "JBChartHeaderView.h"
#import "JBLineChartFooterView.h"
#import "JBChartInformationView.h"

#define ARC4RANDOM_MAX 0x100000000

typedef NS_ENUM(NSInteger, JBLineChartLine){
	JBLineChartLineSolid,
	JBLineChartLineDashed,
	JBLineChartLineCount
};

// Numerics
CGFloat const kJBLineChartViewControllerChartHeight = 250.0f;
CGFloat const kJBLineChartViewControllerChartPadding = 10.0f;
CGFloat const kJBLineChartViewControllerChartHeaderHeight = 75.0f;
CGFloat const kJBLineChartViewControllerChartHeaderPadding = 20.0f;
CGFloat const kJBLineChartViewControllerChartFooterHeight = 20.0f;
CGFloat const kJBLineChartViewControllerChartSolidLineWidth = 6.0f;
CGFloat const kJBLineChartViewControllerChartSolidLineDotRadius = 5.0f;
CGFloat const kJBLineChartViewControllerChartDashedLineWidth = 2.0f;
NSInteger const kJBLineChartViewControllerMaxNumChartPoints = 7;

// Strings
NSString * const kJBLineChartViewControllerNavButtonViewKey = @"view";

@interface JBLineChartViewController () <JBLineChartViewDelegate, JBLineChartViewDataSource>

@property (nonatomic, strong) JBLineChartView *lineChartView;
@property (nonatomic, strong) JBChartInformationView *informationView;
@property (nonatomic, strong) NSArray *chartData;

// Buttons
- (void)chartToggleButtonPressed:(id)sender;

// Helpers
- (void)initFakeData;
- (NSArray *)largestLineData; // largest collection of fake line data

@end

@implementation JBLineChartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self)
	{
		[self initFakeData];
	}
	return self;
}

- (void)dealloc
{
	_lineChartView.delegate = nil;
	_lineChartView.dataSource = nil;
}

#pragma mark - Data

// 初始化数据
- (void)initFakeData
{
	NSMutableArray *mutableLineCharts = [NSMutableArray array];
	for (int lineIndex=0; lineIndex<JBLineChartLineCount; lineIndex++)
	{
		NSMutableArray *mutableChartData = [NSMutableArray array];
		for (int i=0; i<kJBLineChartViewControllerMaxNumChartPoints; i++)
		{
			[mutableChartData addObject:[NSNumber numberWithFloat:((double)arc4random() / ARC4RANDOM_MAX)]]; // random number between 0 and 1
		}
		[mutableLineCharts addObject:mutableChartData];
	}
	_chartData = [NSArray arrayWithArray:mutableLineCharts];
}

// 最近的数据
- (NSArray *)largestLineData
{
	NSArray *largestLineData = nil;
	for (NSArray *lineData in self.chartData)
	{
		if ([lineData count] > [largestLineData count])
		{
			largestLineData = lineData;
		}
	}
	return largestLineData;
}

- (void)loadView
{
	[super loadView];
	
	self.navigationItem.rightBarButtonItem = [self chartToggleButtonWithTarget:self action:@selector(chartToggleButtonPressed:)];
	
	self.lineChartView = [JBLineChartView new];
	self.lineChartView.frame = CGRectMake(kJBLineChartViewControllerChartPadding, kJBLineChartViewControllerChartPadding, self.view.bounds.size.width - (kJBLineChartViewControllerChartPadding * 2), kJBLineChartViewControllerChartHeight);
	self.lineChartView.delegate = self;
	self.lineChartView.dataSource = self;
    
	self.lineChartView.headerPadding = kJBLineChartViewControllerChartHeaderPadding;
	self.lineChartView.backgroundColor = kJBColorLineChartBackground;
	
	JBChartHeaderView *headerView = [[JBChartHeaderView alloc] initWithFrame:CGRectMake(kJBLineChartViewControllerChartPadding, ceil(self.view.bounds.size.height * 0.5) - ceil(kJBLineChartViewControllerChartHeaderHeight * 0.5), self.view.bounds.size.width - (kJBLineChartViewControllerChartPadding * 2), kJBLineChartViewControllerChartHeaderHeight)];
    
	headerView.titleLabel.text = [kJBStringLabelAverageDailyRainfall uppercaseString];
	headerView.titleLabel.textColor = kJBColorLineChartHeader;
	headerView.titleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.25];
	headerView.titleLabel.shadowOffset = CGSizeMake(0, 1);
    headerView.titleLabel.backgroundColor = [UIColor yellowColor];
	headerView.subtitleLabel.text = kJBStringLabel2013;
    headerView.backgroundColor = [UIColor grayColor];
    headerView.subtitleLabel.backgroundColor = [UIColor blueColor];
	headerView.subtitleLabel.textColor = kJBColorLineChartHeader;
	headerView.subtitleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.25];
	headerView.subtitleLabel.shadowOffset = CGSizeMake(0, 1);
	headerView.separatorColor = kJBColorLineChartHeaderSeparatorColor;
	self.lineChartView.headerView = headerView;
	
	JBLineChartFooterView *footerView = [[JBLineChartFooterView alloc] initWithFrame:CGRectMake(kJBLineChartViewControllerChartPadding, ceil(self.view.bounds.size.height * 0.5) - ceil(kJBLineChartViewControllerChartFooterHeight * 0.5), self.view.bounds.size.width - (kJBLineChartViewControllerChartPadding * 2), kJBLineChartViewControllerChartFooterHeight)];
	footerView.backgroundColor = [UIColor clearColor];
	footerView.leftLabel.textColor = [UIColor blackColor];
	footerView.rightLabel.textColor = [UIColor blackColor];
    footerView.centerLabel.textColor = [UIColor redColor];
	footerView.sectionCount = [[self largestLineData] count];
    footerView.leftLabel.text = @"footer left";
    footerView.rightLabel.text = @"footer right";
    footerView.centerLabel.text = @"footer center";
    footerView.leftLabel.backgroundColor = [UIColor purpleColor];
    footerView.rightLabel.backgroundColor = [UIColor yellowColor];
	self.lineChartView.footerView = footerView;
	[self.view addSubview:self.lineChartView];
//  上面展示了头部和底部
    
	self.informationView = [[JBChartInformationView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, CGRectGetMaxY(self.lineChartView.frame), self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetMaxY(self.lineChartView.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame))];
//    [self.informationView setValueAndUnitTextColor:[UIColor blackColor]];
    [self.informationView setValueColor:[UIColor blueColor]];
    [self.informationView setUnitTextColor:[UIColor greenColor]];
    [self.informationView setTitleColor:[UIColor purpleColor]];
    self.informationView.titleLabel.backgroundColor = [UIColor yellowColor];
	[self.informationView setTitleTextColor:kJBColorLineChartHeader];
	[self.informationView setTextShadowColor:nil];
	[self.informationView setSeparatorColor:kJBColorLineChartHeaderSeparatorColor];
	[self.view addSubview:self.informationView];
    self.informationView.backgroundColor = [UIColor redColor];
//  上面的内容，基本上除了图标上面的，基本额外的都处理了
    
	[self.lineChartView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.lineChartView setState:JBChartViewStateExpanded];
}

#pragma mark - JBChartViewDataSource

// 头部和底部的内容
- (BOOL)shouldExtendSelectionViewIntoHeaderPaddingForChartView:(JBChartView *)chartView {
	return NO;
}

- (BOOL)shouldExtendSelectionViewIntoFooterPaddingForChartView:(JBChartView *)chartView
{
	return NO;
}

#pragma mark - JBLineChartViewDataSource

// 显示展示多少行
- (NSUInteger)numberOfLinesInLineChartView:(JBLineChartView *)lineChartView {
	return [self.chartData count];
}

//一行中的值
- (NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex {
	return [[self.chartData objectAtIndex:lineIndex] count];
}

// 是否展示 
- (BOOL)lineChartView:(JBLineChartView *)lineChartView showsDotsForLineAtLineIndex:(NSUInteger)lineIndex {
//    return lineIndex == JBLineChartViewLineStyleDashed;
    return YES;
    // 这个有什么关系？ 这个应该是用来展示对应的线条
}

// 这个和行数有什么关系？
- (BOOL)lineChartView:(JBLineChartView *)lineChartView smoothLineAtLineIndex:(NSUInteger)lineIndex {
//    return lineIndex == JBLineChartViewLineStyleSolid;
    return YES;
}

#pragma mark - JBLineChartViewDelegate

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex { // 应该分别对应着 行、竖角标
	return [[[self.chartData objectAtIndex:lineIndex] objectAtIndex:horizontalIndex] floatValue];
}

// 点击的脚标
- (void)lineChartView:(JBLineChartView *)lineChartView didSelectLineAtIndex:(NSUInteger)lineIndex horizontalIndex:(NSUInteger)horizontalIndex touchPoint:(CGPoint)touchPoint {
	NSNumber *valueNumber = [[self.chartData objectAtIndex:lineIndex] objectAtIndex:horizontalIndex];
	[self.informationView setValueText:[NSString stringWithFormat:@"%.2f", [valueNumber floatValue]] unitText:kJBStringLabelMm];
	[self.informationView setTitleText:lineIndex == JBLineChartLineSolid ? kJBStringLabelMetropolitanAverage : kJBStringLabelNationalAverage];
	[self.informationView setHidden:NO animated:YES];
	[self setTooltipVisible:YES animated:YES atTouchPoint:touchPoint];
}

- (void)didDeselectLineInLineChartView:(JBLineChartView *)lineChartView {
	[self.informationView setHidden:YES animated:YES];
	[self setTooltipVisible:NO animated:YES];
}

// 行的颜色
- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex
{
	return (lineIndex == JBLineChartLineSolid) ? kJBColorLineChartDefaultSolidLineColor: nil;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView fillColorForLineAtLineIndex:(NSUInteger)lineIndex
{
	return (lineIndex == JBLineChartLineSolid) ? kJBColorLineChartDefaultSolidFillColor : nil;
}

// 对应脚标下的行的线条
- (CAGradientLayer *)lineChartView:(JBLineChartView *)lineChartView gradientForLineAtLineIndex:(NSUInteger)lineIndex
{
	if (lineIndex == JBLineChartLineSolid)
	{
		return nil;
	}
	else
	{
		CAGradientLayer *gradient = [CAGradientLayer new];
		gradient.startPoint = CGPointMake(0.0, 0.0);
		gradient.endPoint = CGPointMake(1.0, 0.0);
		gradient.colors = @[(id)kJBColorLineChartDefaultGradientStartColor.CGColor, (id)kJBColorLineChartDefaultGradientEndColor.CGColor];
		return gradient;
	}
}

//一行中对应的竖直的颜色
- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex {
	return (lineIndex == JBLineChartLineSolid) ? kJBColorLineChartDefaultSolidLineColor: kJBColorLineChartDefaultDashedLineColor;
}

//一行的宽
- (CGFloat)lineChartView:(JBLineChartView *)lineChartView widthForLineAtLineIndex:(NSUInteger)lineIndex {
	return (lineIndex == JBLineChartLineSolid) ? kJBLineChartViewControllerChartSolidLineWidth: kJBLineChartViewControllerChartDashedLineWidth;
}

// 圆角 （某列）
- (CGFloat)lineChartView:(JBLineChartView *)lineChartView dotRadiusForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex {
	return (lineIndex == JBLineChartLineSolid) ? 0.0: kJBLineChartViewControllerChartSolidLineDotRadius;
}

//选择的颜色
- (UIColor *)lineChartView:(JBLineChartView *)lineChartView verticalSelectionColorForLineAtLineIndex:(NSUInteger)lineIndex {
	return [UIColor whiteColor];
}

//选中的时候的颜色
- (UIColor *)lineChartView:(JBLineChartView *)lineChartView selectionColorForLineAtLineIndex:(NSUInteger)lineIndex {
	return (lineIndex == JBLineChartLineSolid) ? kJBColorLineChartDefaultSolidSelectedLineColor: nil;
}

// 选中点的时候的颜色
- (UIColor *)lineChartView:(JBLineChartView *)lineChartView selectionColorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex {
	return (lineIndex == JBLineChartLineSolid) ? kJBColorLineChartDefaultSolidSelectedLineColor: kJBColorLineChartDefaultDashedSelectedLineColor;
}

//行的样式
- (JBLineChartViewLineStyle)lineChartView:(JBLineChartView *)lineChartView lineStyleForLineAtLineIndex:(NSUInteger)lineIndex {
	return (lineIndex == JBLineChartLineSolid) ? JBLineChartViewLineStyleSolid : JBLineChartViewLineStyleDashed;
}

//颜色的样式
- (JBLineChartViewColorStyle)lineChartView:(JBLineChartView *)lineChartView colorStyleForLineAtLineIndex:(NSUInteger)lineIndex
{
	return (lineIndex == JBLineChartLineSolid) ? JBLineChartViewColorStyleSolid : JBLineChartViewColorStyleGradient;
}

#pragma mark - Buttons

- (void)chartToggleButtonPressed:(id)sender
{
	UIView *buttonImageView = [self.navigationItem.rightBarButtonItem valueForKey:kJBLineChartViewControllerNavButtonViewKey];
	buttonImageView.userInteractionEnabled = NO;
	
	CGAffineTransform transform = self.lineChartView.state == JBChartViewStateExpanded ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformMakeRotation(0);
	buttonImageView.transform = transform;
	
	[self.lineChartView setState:self.lineChartView.state == JBChartViewStateExpanded ? JBChartViewStateCollapsed : JBChartViewStateExpanded animated:YES callback:^{
		buttonImageView.userInteractionEnabled = YES;
	}];
}

#pragma mark - Overrides

- (JBChartView *)chartView
{
	return self.lineChartView;
}

@end
