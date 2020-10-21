//
//  TonescapePlot.m
//  Audio Control
//
//  Created by Alain Hsu on 10/11/16.
//  Copyright © 2016 tymphanysz. All rights reserved.
//

#import "TonescapePlot.h"

@implementation TonescapePlot


#pragma mark -write tonescape

+ (NSData*)datapacketWithVolume:(int)volume power:(int)power x:(float)x y:(float)y z:(float)z {
    NSMutableData *datapacket = [NSMutableData new];
    
    double Gx1 = [self gainFunction:x];
    double Gx2 = [self gainFunction:-x];
    
    double Gy1 = [self gainFunction:y];
    double Gy2 = [self gainFunction:-y];
    
    double Gz = [self GzFunction:z];
    
    double K5_44k1 = [self k5FunctionWithFs:44100 andZ:z];
    double K5_48k = [self k5FunctionWithFs:48000 andZ:z];
    
    double K6_44k1 = [self k6FunctionWithFs:44100 andZ:z];
    double K6_48k = [self k6FunctionWithFs:48000 andZ:z];
    
    [datapacket appendData:[self hexToBytes:volume length:2]];
    [datapacket appendData:[self hexToBytes:power length:2]];
    [datapacket appendData:[self hexToBytes:(int)Gx1 length:4]];
    [datapacket appendData:[self hexToBytes:(int)Gx2 length:4]];
    [datapacket appendData:[self hexToBytes:(int)Gy1 length:4]];
    [datapacket appendData:[self hexToBytes:(int)Gy2 length:4]];
    [datapacket appendData:[self hexToBytes:(int)Gz length:4]];
    [datapacket appendData:[self hexToBytes:(int)K5_44k1 length:6]];
    [datapacket appendData:[self hexToBytes:(int)K5_48k length:6]];
    [datapacket appendData:[self hexToBytes:(int)K6_44k1 length:6]];
    [datapacket appendData:[self hexToBytes:(int)K6_48k length:6]];

    return datapacket;
}

+ (double)gainFunction:(float)q {
    
    double g = 0.03782749 * pow(q, 3) + 0.49848716 * pow(q, 2) + 0.46209961 * q - 0.00193403;
    
    if (g > 0) {
        return g * pow(2, 15);
    }else{
        return (2+g)*pow(2, 15);
    }
}

+ (double)k5FunctionWithFs:(int)fs andZ:(float)z{
    
    double f5 = 1500 * z + 250;
    
    double k5 = ((M_PI * f5 / fs) -1)/((M_PI * f5 / fs) +1);
    
    if (k5 >0) {
        return k5 * pow(2, 23);
    }else{
        return (2+k5)*pow(2, 23);
    }
}

+ (double)k6FunctionWithFs:(int)fs andZ:(float)z{
    
    double f6 = -100 * z + 250;

    double k6 = ((M_PI * f6 / fs) -1)/((M_PI * f6 / fs) +1);
    
    if (k6 > 0) {
        return k6 * pow(2, 23);
    }else{
        return (2+k6)*pow(2, 23);
    }
}

+ (double)GzFunction:(float)z {
    
    return 0.5 * z *pow(2, 15);
}

#pragma mark -read tonescape
+ (NSInteger)readPower:(NSData*)data {
    return  [self parseIntFromData:[data subdataWithRange:NSMakeRange(1, 1)]];
}

//+ (NSInteger)readVolume:(NSData*)data {
//    return [self parseIntFromData:[data subdataWithRange:NSMakeRange(0, 1)]];
//}

+ (NSInteger)readX:(NSData*)data {
    unsigned Gx1 = [self parseIntFromData:[data subdataWithRange:NSMakeRange(2, 2)]];
    NSInteger x1 = [self inverseGainFunction:Gx1];
    if (x1 > 0) {
        return x1;
    }else{
        unsigned Gx2 = [self parseIntFromData:[data subdataWithRange:NSMakeRange(4, 2)]];
        NSInteger x2 = [self inverseGainFunction:Gx2];
        if (x1 + x2 == 0) {
            return x1;
        }else{
            return -x2;
        }
    }
}

+ (NSInteger)readY:(NSData*)data {
    unsigned Gy1 = [self parseIntFromData:[data subdataWithRange:NSMakeRange(6, 2)]];
    NSInteger y1 = [self inverseGainFunction:Gy1];
    if (y1 > 0) {
        return y1;
    }else{
        unsigned Gy2 = [self parseIntFromData:[data subdataWithRange:NSMakeRange(8, 2)]];
        NSInteger y2 = [self inverseGainFunction:Gy2];
        if (y1 + y2 == 0) {
            return y1;
        }else{
            return -y2;
        }
    }}

+ (NSInteger)readZ:(NSData*)data {
    unsigned Gz = [self parseIntFromData:[data subdataWithRange:NSMakeRange(10, 2)]];
    return [self inverseGzFunction:Gz];
}


+ (NSInteger)inverseGainFunction:(unsigned)value {
    float g = (float)value;
    double G = g/pow(2, 15);
    if (G > 1) {
        G = G - 2;
    }
    double q = [self equationsInShengjinFormulas:G];
    q = round(q * 10);
    
    return (NSInteger)q;
}

+ (NSInteger)inverseGzFunction:(unsigned)Gz {
    float z = Gz / pow(2, 15) * 2;
    return round(z * 10);
}

#pragma mark -helper
+ (NSData*)hexToBytes:(int)value length:(int)length {
    
    NSString *str = [NSString stringWithFormat:@"%0x",value];
    
    while (str.length < length) {
        str = [NSString stringWithFormat:@"0%@",str];
    }
    
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= str.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [str substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }

    return data;
}

+ (unsigned)parseIntFromData:(NSData *)data {
    
    NSString *dataDescription = [data description];
    NSString *dataAsString = [dataDescription substringWithRange:NSMakeRange(1, [dataDescription length]-2)];
    
    unsigned intData = 0;
    NSScanner *scanner = [NSScanner scannerWithString:dataAsString];
    [scanner scanHexInt:&intData];
    return intData;
}

+ (double)equationsInShengjinFormulas:(double)G {
    double a = 0.03782749;
    double b = 0.49848716;
    double c = 0.46209961;
    double d = -G-0.00193403;
    
    double x0, x1, x2;
    
    double A, B, C, Delta;
    double theta;
    double y1, y2;
    
    //盛金公式 Shengjin's formulas
    A=b*b-3*a*c;
    B=b*c-9*a*d;
    C=c*c-3*b*d;
    Delta=B*B-4*A*C;
    
    if (A==0 && B==0)
    {
        x0=-b/a;
        x0*=(0.3333333333333333333);
        
        x1=x0;
        x2=x0;
    }
    else if (Delta>0)	//two imaginary roots，equal to 0
    {
        Delta=sqrt(Delta);
        
        y1=A*b;
        y1-=1.5*a*B;
        y1+=1.5*a*Delta;
        y1=pow(y1,(double)(0.3333333333333333333));
        
        y2=y1-3*a*Delta;
        y2=pow(y2,(double)(0.3333333333333333333));
        
        x0=(-b-(y1+y2));
        x0/=a;
        x0*=(0.3333333333333333333);
        
        x1=0;
        x2=0;
    }
    else if (Delta==0)	//two multiple roots
    {
        x0=B/A;
        x1=-x0*0.5;
        x2=x1;
        
        x0=x0-b/a;
    }
    else
    {
        theta=2*A*b;
        theta-=3*a*B;
        theta*=0.5;
        theta/=A;
        theta/=sqrt(A);
        theta=acos(theta);
        
        theta=(2*A*b-3*a*B)*0.5/sqrt(A*A*A);
        theta=acos(theta);
        
        
        x0=sqrt(A)*cos(theta*(0.3333333333333333333));
        Delta=sqrt(3.0*A)*sin(theta*(0.3333333333333333333));
        
        x1=-b+x0+Delta;
        x1*=(0.3333333333333333333);
        x1/=a;
        
        x2=-b+x0-Delta;
        x2*=(0.3333333333333333333);
        x2/=a;
        
        x0*=-2;
        x0-=b;
        x0*=(0.3333333333333333333);
        x0/=a;
        
        // 		x0=(-b-2*sqrt(A)*cos(theta/3.0))/3.0/a;
        // 		x1=(-b+sqrt(A)*(cos(theta/3.0)+sqrt(3.0)*sin(theta/3.0)))/3.0/a;
        // 		x2=(-b+sqrt(A)*(cos(theta/3.0)-sqrt(3.0)*sin(theta/3.0)))/3.0/a;
    }
    //sort
    if (x0<x1)
    {
        Delta=x0;
        x0=x1;
        x1=Delta;
    }
    if (x0<x2)
    {
        Delta=x0;
        x0=x2;
        x2=Delta;
    }
    if (x1<x2)
    {
        Delta=x1;
        x1=x2;
        x2=Delta;
    }
    
//    NSLog(@"%g,%g,%g",x0,x1,x2);
    
    return x0;
}

@end
