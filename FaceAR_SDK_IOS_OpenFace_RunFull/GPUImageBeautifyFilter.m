//
//  GPUImageBeautifyFilter.m
//  BeautifyFaceDemo
//
//

#import "GPUImageBeautifyFilter.h"

// Internal CombinationFilter(It should not be used outside)
@interface GPUImageCombinationFilter : GPUImageThreeInputFilter
{
    GLint smoothDegreeUniform;
}

@property (nonatomic, assign) CGFloat intensity;

@end

NSString *const kGPUImageBeautifyFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 varying highp vec2 textureCoordinate3;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform sampler2D inputImageTexture3;
 uniform mediump float smoothDegree;
 
 void main()
 {
     highp vec4 bilateral = texture2D(inputImageTexture, textureCoordinate);
     highp vec4 canny = texture2D(inputImageTexture2, textureCoordinate2);
     highp vec4 origin = texture2D(inputImageTexture3,textureCoordinate3);
     highp vec4 smooth;
     lowp float r = origin.r;
     lowp float g = origin.g;
     lowp float b = origin.b;
     
     if (canny.r < 0.2 && r > 0.375 && g > 0.2 && b > 0.0784 && r > b && (max(max(r, g), b) - min(min(r, g), b)) > 0.0588 && abs(r-g) > 0.0588) {
         smooth = (1.0 - smoothDegree) * (origin - bilateral) + bilateral;
     }
     else {
         smooth = origin;
     }
     lowp float a=(smooth.r+smooth.g+smooth.b)/3.0;
     lowp float k=a*(1.0+smoothDegree*0.8*exp(-a/25.5));
     lowp float rt=0.6*smoothDegree;
     
     smooth.r=k*rt+smooth.r*(1.0-rt);
     smooth.g=k*rt+smooth.g*(1.0-rt);
     smooth.b=k*rt+smooth.b*(1.0-rt);
     /*
      smooth.r=a+smoothDegree*(smooth.r-a)*0.9;
      smooth.g=a+smoothDegree*(smooth.g-a)*0.9;
      smooth.b=a+smoothDegree*(smooth.b-a)*0.9;
      */
     /*
      smooth.r=smooth.r*(1.0+smoothDegree*0.8*exp(-smooth.r*1.));
      smooth.g=smooth.g*(1.0+smoothDegree*0.8*exp(-smooth.g*1.));
      smooth.b=smooth.b*(1.0+smoothDegree*0.8*exp(-smooth.b*1.));
      */

     gl_FragColor = smooth;
 }
 );

@implementation GPUImageCombinationFilter

- (id)init:(CGFloat)intensity {
    if (self = [super initWithFragmentShaderFromString:kGPUImageBeautifyFragmentShaderString]) {
        smoothDegreeUniform = [filterProgram uniformIndex:@"smoothDegree"];
    }
    self.intensity = intensity;
    return self;
}

- (void)setIntensity:(CGFloat)intensity {
    _intensity = intensity;
    [self setFloat:intensity forUniform:smoothDegreeUniform program:filterProgram];
}

@end

@implementation GPUImageBeautifyFilter
-(void)SetValueWithFilter:(GLfloat)value;{
    
    // First pass: face smoothing filter
    bilateralFilter = [[GPUImageBilateralFilter alloc] init];
    bilateralFilter.distanceNormalizationFactor = 2;
    //bilateralFilter.texelSpacingMultiplier=(GLint)(value*5);
    [self addFilter:bilateralFilter];
    
    // Second pass: edge detection
    cannyEdgeFilter = [[GPUImageCannyEdgeDetectionFilter alloc] init];
    [self addFilter:cannyEdgeFilter];
    
    // Third pass: combination bilateral, edge detection and origin
    combinationFilter = [[GPUImageCombinationFilter alloc] init:value];
    [self addFilter:combinationFilter];
    
    // Adjust HSB
    hsbFilter = [[GPUImageHSBFilter alloc] init];
    [hsbFilter adjustBrightness:1.0+value*0.1];
    [hsbFilter adjustSaturation:1.0+value*0.1];
    
    [bilateralFilter addTarget:combinationFilter];
    [cannyEdgeFilter addTarget:combinationFilter];
    
    [combinationFilter addTarget:hsbFilter];
    
    self.initialFilters = [NSArray arrayWithObjects:bilateralFilter,cannyEdgeFilter,combinationFilter,nil];
    self.terminalFilter = hsbFilter;

}
- (id)init;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
        return self;
}
-(void)setFilterWithValue:(GLfloat)value;
{
    
  
}

#pragma mark -
#pragma mark GPUImageInput protocol

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
{
    for (GPUImageOutput<GPUImageInput> *currentFilter in self.initialFilters)
    {
        if (currentFilter != self.inputFilterToIgnoreForUpdates)
        {
            if (currentFilter == combinationFilter) {
                textureIndex = 2;
            }
            [currentFilter newFrameReadyAtTime:frameTime atIndex:textureIndex];
        }
    }
}

- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex;
{
    for (GPUImageOutput<GPUImageInput> *currentFilter in self.initialFilters)
    {
        if (currentFilter == combinationFilter) {
            textureIndex = 2;
        }
        [currentFilter setInputFramebuffer:newInputFramebuffer atIndex:textureIndex];
    }
}

@end
