//
//  PEQPlot.m
//  SVS16UltraApp
//
//  Created by Lam Yick Hong on 16/9/15.
//  Copyright (c) 2015 primax. All rights reserved.
//

#import "PEQPlot.h"
#import <complex.h>

static NSString *const kData   = @"Data Source Plot";
static NSString *const kFirst  = @"First Derivative";
static NSString *const kSecond = @"Second Derivative";

@interface PEQPlot()

@property (nonatomic, strong)CPTGraph* graph;

@end

@implementation PEQPlot

-(instancetype)init
{
    if ( (self = [super init]) ) {
        self.title   = @"Parametric Equalizer Plot";
        self.section = kLinePlots;
        
        self.peqSettings = [[NSMutableArray alloc] init];
        self.enableColour = [UIColor whiteColor];
        self.disableColor = [UIColor lightGrayColor];
        self.selectedColor = [UIColor greenColor];
        self.totalColor = nil;
    }
    
    return self;
}

-(void)renderInGraphHostingView:(CPTGraphHostingView *)hostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = hostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(hostingView.bounds);
#endif
    
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:graph toHostingView:hostingView];
    
    graph.plotAreaFrame.paddingLeft   = 0;
    graph.plotAreaFrame.paddingTop    = 0;
    graph.plotAreaFrame.paddingRight  = 0;
    graph.plotAreaFrame.paddingBottom = 0;
    graph.plotAreaFrame.masksToBorder  = NO;
    
    
    // Setup scatter plot space
    
    CGFloat yBottom = -12.0;
    CGFloat yTop = 12;
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xScaleType = CPTScaleTypeLog;
    plotSpace.allowsUserInteraction = NO;
    
    plotSpace.xRange                = [CPTPlotRange plotRangeWithLocation:@20.0 length:@200.0];
    plotSpace.yRange                = [CPTPlotRange plotRangeWithLocation:[NSNumber numberWithFloat:yBottom] length:[NSNumber numberWithFloat:(yTop - yBottom)]];
    
    CPTXYAxisSet* axisSet = (CPTXYAxisSet *)graph.axisSet;
    
    CPTXYAxis *logAxis = axisSet.xAxis;
    logAxis.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    logAxis.minorTicksPerInterval       = 15;
    logAxis.tickDirection               = CPTSignNone;
    
    
    CPTXYAxis *linearAxis = axisSet.yAxis;
    linearAxis.labelingPolicy              = CPTAxisLabelingPolicyFixedInterval;
    linearAxis.minorTicksPerInterval       = 4;
    linearAxis.tickDirection                = CPTSignNone;
    
    [self updateDataOnGraph:graph];
    
    self.graph = graph;
}

- (void)valueOfPoint:(CGPoint)point freq:(CGFloat*)freq boost:(CGFloat*)boost
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)(self.graph).defaultPlotSpace;
    NSDecimal plotPoint[2];
    [plotSpace plotPoint:plotPoint numberOfCoordinates:2 forPlotAreaViewPoint:point];
    double x = CPTDecimalDoubleValue(plotPoint[CPTCoordinateX]);
    double y = CPTDecimalDoubleValue(plotPoint[CPTCoordinateY]);
    
    //calibrate the taken out value. Why?
    x = x - 4.331162;
    y = -y - 4.8057;
    
    //the y is suspiciously even less accurate. hard code and calculate
    CGRect bound = self.graph.hostingView.bounds;
    double ratio = point.y / bound.size.height;
    
    double bottom = plotSpace.yRange.locationDouble;
    double top = bottom + plotSpace.yRange.lengthDouble;
    
    y = top - ((top - bottom) * ratio);
 
    *freq = x;
    *boost = y;
}

- (CGPoint)pointOfPeakOfIndex:(NSInteger)index
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)(self.graph).defaultPlotSpace;
    
    NSDictionary* peq = [self.peqSettings objectAtIndex:index];
    
    double fc = [[peq objectForKey:@"freq"] doubleValue];
    double b = [[peq objectForKey:@"boost"] doubleValue];
    
    NSDecimal plotPoint[2];
    plotPoint[0] = CPTDecimalFromDouble(fc);
    plotPoint[1] = CPTDecimalFromDouble(b);
    
    CGPoint p = [plotSpace plotAreaViewPointForPlotPoint:plotPoint numberOfCoordinates:2];
    
    //y is all wrong. unsure why. let's calculate ourselves for now
    double bottom = plotSpace.yRange.locationDouble;
    double top = bottom + plotSpace.yRange.lengthDouble;
    
    double ratio = (top - b) / (top - bottom);
    
    CGRect bound = self.graph.hostingView.bounds;
    double y = ratio * bound.size.height;
    
    p = CGPointMake(p.x, y);
    
    return p;
}

- (void)updateDataOnGraph:(CPTGraph*)graph;
{
    NSInteger count = 0;

    for(NSDictionary* peq in self.peqSettings)
    {
        
        BOOL on = [[peq objectForKey:@"on"] boolValue];
        
        CPTDataSourceBlock block       = nil;
        CPTColor *lineColor            = nil;
        
        block       = ^(double xVal) {
            
            double fc = [[peq objectForKey:@"freq"] doubleValue];
            double q = [[peq objectForKey:@"qfactor"] doubleValue];
            double b = [[peq objectForKey:@"boost"] doubleValue];
            
            double complex hz = [self freqFromCentralFrequency:fc boost:b qFactor:q xVal:xVal];

            double yVal = 20* log10(cabs(hz));
 
            return yVal;
        };
        
        if(self.selectedIndex == count)
        {
            lineColor = [CPTColor colorWithCGColor:self.selectedColor.CGColor];
            
        }else{
            
            if(!on)
            {
                lineColor = [CPTColor colorWithCGColor:self.disableColor.CGColor];
                
            }else{
               
                lineColor = [CPTColor colorWithCGColor:self.enableColour.CGColor];
            }
        }
        
        
        //get the linePlot or createOne if not exist
        NSString* kIdentifier = [NSString stringWithFormat:@"PEQ -  %ld", count];
        
        CPTScatterPlot *linePlot   = (CPTScatterPlot*)[self.graph plotWithIdentifier:kIdentifier];
        
        if(!linePlot)
        {
            linePlot = [[CPTScatterPlot alloc] init];
            linePlot.identifier = [NSString stringWithFormat:@"PEQ -  %ld", count];
            
            //selected plot should always be on top
            if(self.selectedIndex == count){
                
                [graph addPlot:linePlot];
                
            }else{
                
                [graph insertPlot:linePlot atIndex:0];
            }
        }
        
        CPTMutableLineStyle *lineStyle = [linePlot.dataLineStyle mutableCopy];
        lineStyle.lineWidth    = 1.0;
        lineStyle.lineColor    = lineColor;
        linePlot.dataLineStyle = lineStyle;
        
        linePlot.alignsPointsToPixels = NO;
        linePlot.showLabels = NO;
        
        CPTFunctionDataSource *plotDataSource = nil;
        
        plotDataSource = [CPTFunctionDataSource dataSourceForPlot:linePlot withBlock:block];
        
        plotDataSource.resolution = 2.0;

        [linePlot reloadData];

        count++;
        
    }
    
    //The total curve
    CPTDataSourceBlock block       = nil;
    CPTColor *lineColor            = nil;
    
    block       = ^(double xVal) {
        
        double complex hz = 1.0;
        
        for(NSDictionary* peq in self.peqSettings)
        {
            BOOL on = [[peq objectForKey:@"on"] boolValue];
            
            if(on)
            {
                double fc = [[peq objectForKey:@"freq"] doubleValue];
                double q = [[peq objectForKey:@"qfactor"] doubleValue];
                double b = [[peq objectForKey:@"boost"] doubleValue];
                
                hz *= [self freqFromCentralFrequency:fc boost:b qFactor:q xVal:xVal];
            }
        }
        
        
        double yVal = 20* log10(cabs(hz));
        
        return yVal;
    };
    
    lineColor = [CPTColor colorWithCGColor:[self invert:self.selectedColor].CGColor];
    
    //get the linePlot or createOne if not exist
    NSString* kIdentifier = @"PEQ - total";
    
    CPTScatterPlot *linePlot   = (CPTScatterPlot*)[self.graph plotWithIdentifier:kIdentifier];
    
    if(!linePlot)
    {
        linePlot = [[CPTScatterPlot alloc] init];
        linePlot.identifier = kIdentifier;
        
        CPTMutableLineStyle *lineStyle = [linePlot.dataLineStyle mutableCopy];
        lineStyle.lineWidth    = 2.0;
        lineStyle.lineColor    = lineColor;
        linePlot.dataLineStyle = lineStyle;
        
        linePlot.alignsPointsToPixels = NO;
        linePlot.showLabels = NO;
        
        [graph insertPlot:linePlot atIndex:0];
    }
    
    CPTFunctionDataSource *plotDataSource = nil;
    
    plotDataSource = [CPTFunctionDataSource dataSourceForPlot:linePlot withBlock:block];
    
    plotDataSource.resolution = 2.0;
    
    [linePlot reloadData];
    
}

- (void)updateGraph
{
    [self updateDataOnGraph:self.graph];
}

- (double complex)freqFromCentralFrequency:(double)fc boost:(double)b qFactor:(double)q xVal:(double) x
{
    double fs = 48000.0;
    double ts = 1/fs;
    double w0 = 2.0 * M_PI * (fc/fs);
    
    double bigA = pow(10.0, b / 40.0);
    double alpha = sin(w0) / (2.0 * bigA * q);
    
    double a0 = 1.0 + (alpha / bigA);
    double a00 = a0 / a0;
    double a1 = -2.0 * cos(w0);
    a1 = a1 / a0;
    double a2 = 1.0 - (alpha / bigA);
    a2 = a2 / a0;
    double b0 = (1.0 + alpha * bigA);
    b0 = b0 / a0;
    double b1 = -(2.0 * cos(w0));
    b1 = b1 / a0;
    double b2 = 1.0 - (alpha * bigA);
    b2 = b2 / a0;
    
    double w = 2.0 * M_PI * x;
    double complex s = 1.0 + w * I;
    double complex z = (2 + s * ts) / (2 - s * ts);
    
    return (double complex)(b0 + (b1 * cpow(z, -1)) + (b2 * cpow(z, -2))) / (double complex)(a00 + (a1 * cpow(z, -1)) + (a2 * cpow(z, -2)));
}

- (UIColor*)invert:(UIColor*)color
{
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    
    [color getRed:&red green:&green blue:&blue alpha:nil];
    
    return [UIColor colorWithRed:(1.0 - red) green:(1.0 - green) blue:(1.0 - blue) alpha:1.0];
}


@end
