//
//  SHGLView.m
//  OpenGLDemo
//
//  Created by Ray on 2023/3/8.
//

#import "SHGLTool.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/EAGL.h>
#import "SHGLView.h"
static char* COMMON_VERTEX_SHADER = "attribute vec4 position; \n"
"attribute vec2 texcoord; \n"
"varying vec2 v_texcoord; \n"
" \n" "void main(void) \n"
"{ \n" " gl_Position = position; \n"
" v_texcoord = texcoord; \n" "} \n";

static char* COMMON_FRAG_SHADER = "precision highp float; \n"
"varying highp vec2 v_texcoord; \n"
"uniform sampler2D texSampler; \n"
" \n"
"void main() { \n"
" gl_FragColor = texture2D(texSampler, v_texcoord); \n"
"} \n";


@interface SHGLView ()
{
    EAGLContext* _context;
    GLuint _frameBuffer;
    GLuint renderbuffer;
    GLuint myProgram;
    GLuint positionSlot;
    GLuint colorSlot;
}
@end


@implementation SHGLView

+ (Class)layerClass
{
    return  [CAEAGLLayer class];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initCommon];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initCommon];
    }
    return self;
}

-(void)initCommon {
//    self.backgroundColor = [UIColor clearColor];
    CAEAGLLayer * eaglLayer = (CAEAGLLayer *)self.layer;
    
    [eaglLayer setOpaque: YES];
    //    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGB565, kEAGLDrawablePropertyColorFormat,nil ];
    NSDictionary <NSString *,id>* dict = @{
        kEAGLDrawablePropertyRetainedBacking: [NSNumber numberWithBool:NO],
        kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
        
    };
    
    
    
    [eaglLayer setDrawableProperties: dict];
    [self setupContext];
    [ self setUPBuffer];
    [self setupProgram];
    //    [self connect];
    [self render];
}
/// 设置上下文
-(void)setupContext {
    _context = [[EAGLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES2];
    // 绑定上下文
    [EAGLContext setCurrentContext:_context];
}

-(void)setUPBuffer {
    //    创建帧缓冲区：
    
    glGenFramebuffers(1, &_frameBuffer);
    //    创建绘制缓冲区
    
    glGenRenderbuffers(1, &renderbuffer);
    //    绑定帧缓冲区到渲染管线
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    //    绑定绘制缓存区到渲染管线
    glBindBuffer(GL_RENDERBUFFER, renderbuffer);
    //    为绘制缓冲区分配存储区，此处将CAEAGLLayer的绘制存储区作 为绘制缓冲区的存储区：
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    
    
    //    获取绘制缓冲区的像素高度
    GLint _backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
    //    获取绘制缓冲区的像素宽度
    GLint _backingWidth;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    //    将绘制缓冲区绑定到帧缓冲区：
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderbuffer);
}

-(void)setupProgram {
    //    myProgram
    NSString * vertext = [[NSBundle mainBundle] pathForResource:@"shaderv.glsl" ofType:@""];
    NSString * frgment = [[NSBundle mainBundle] pathForResource:@"shaderf.glsl" ofType:@""];
    myProgram =  [SHGLTool loadShaders:vertext frag:frgment];
    glUseProgram(myProgram);
    positionSlot = glGetAttribLocation(myProgram, "vPosition");
    colorSlot = glGetAttribLocation(myProgram, "a_Color");
    //    positionSlot = GLuint(glGetAttribLocation(myProgram, "vPosition"))
    //    colorSlot = GLuint(glGetAttribLocation(myProgram, "a_Color"))
}

-(void)render {
    glClearColor(0, 1, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glViewport(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    GLfloat vertices[] = {
        0,0.5,0,
        -0.5,-0.5,0,
        0.5,-0.5,0
    };
    GLfloat colors[] = {
        1,0,0,1,
        0,1,0,1,
        0,0,1,1
    };
    
    // 加载顶点数据
    
    glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE,0, vertices);
    glEnableVertexAttribArray(positionSlot);
    
    // 加载颜色数据
    glVertexAttribPointer(colorSlot, 4, GL_FLOAT, GL_FALSE, 0, colors);
    glEnableVertexAttribArray(colorSlot);
    
    // 绘制
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

-(void)testff {
    //    2、顶点数组和索引数组
    //顶点数据，前三个是顶点坐标（x、y、z轴），后面两个是纹理坐标（x，y）
    GLfloat squareVertexData[] =
    {
        0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
        0.5, 0.5, -0.0f,    1.0f, 1.0f, //右上
        -0.5, 0.5, 0.0f,    0.0f, 1.0f, //左上
        
        0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
        -0.5, 0.5, 0.0f,    0.0f, 1.0f, //左上
        -0.5, -0.5, 0.0f,   0.0f, 0.0f, //左下
    };
    
    
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
}


-(void)connect {
    
    
    
    //    创建帧缓冲区：
    GLuint _frameBuffer;
    glGenFramebuffers(1, &_frameBuffer);
    //    创建绘制缓冲区
    GLuint renderbuffer;
    glGenRenderbuffers(1, &renderbuffer);
    //    绑定帧缓冲区到渲染管线
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    //    绑定绘制缓存区到渲染管线
    glBindBuffer(GL_RENDERBUFFER, renderbuffer);
    //    为绘制缓冲区分配存储区，此处将CAEAGLLayer的绘制存储区作 为绘制缓冲区的存储区：
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    
    
    //    获取绘制缓冲区的像素高度
    GLint _backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
    //    获取绘制缓冲区的像素宽度
    GLint _backingWidth;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    //    将绘制缓冲区绑定到帧缓冲区：
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderbuffer);
    
    //    检查FrameBuffer的status：
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if(status != GL_FRAMEBUFFER_COMPLETE){ // failed to make complete frame buffer object
        NSLog(@"==== 失败了 %f",_backingWidth);
    }
    
    //    至此我们就将EAGL与Layer（设备的屏幕）连接起来了，绘制完一 帧之后（当然绘制过程也必须在这个线程之中），调用以下代码：
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    // 这样就可以将绘制的结果显示到屏幕上了。至此我们就搭建好了 iOS平台的OpenGL ES的上下文环境，后面章节会在此基础上进行业务 开发
    
    
    
}


-(void)test {
    //    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
}



/**
 *  c语言编译流程：预编译、编译、汇编、链接
 *  glsl的编译过程主要有glCompileShader、glAttachShader、glLinkProgram三步；
 *  @param vert 顶点着色器
 *  @param frag 片元着色器
 *
 *  @return 编译成功的shaders
 */
- (GLuint)loadShaders:(NSString *)vert frag:(NSString *)frag {
    GLuint verShader, fragShader;
    GLint program = glCreateProgram();
    
    //编译
    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];
    
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    
    
    //释放不需要的shader
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    
    return program;
}

- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
    //读取字符串
    NSString* content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar* source = (GLchar *)[content UTF8String];
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
}




@end
