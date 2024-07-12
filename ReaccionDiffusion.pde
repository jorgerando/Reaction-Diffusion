import com.jogamp.opengl.GL2;
import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.dwgl.DwGLSLProgram;
import com.thomasdiewald.pixelflow.java.dwgl.DwGLTexture;
import com.thomasdiewald.pixelflow.java.imageprocessing.filter.DwFilter;
import processing.core.PApplet;
import processing.opengl.PGraphics2D;

//import com.hamoid.*;

//VideoExport videoExport;

DwGLSLProgram shader_grayscott;
DwGLSLProgram shader_render;

// multipass rendering texture
DwGLTexture.TexturePingPong tex_grayscott = new DwGLTexture.TexturePingPong();

// final render target for display
PGraphics2D tex_render;
PGraphics2D tex_render_new;

DwPixelFlow context;
PGraphics2D nuevaTextura;

float K , F ;

//-------------------------------
  // F = 0.082 , k = 0.06 : Cerebro , coral 
  // F = 0.058 , k = 0.065 : rayas , gusano
  // F = 0.034 , k = 0.0618 : leopardo
  // F = 0.03  , k = 0.063 : puntos auto replicante
  // F = 0.03  , k = 0.0565 : laberintos
  // F = 0.026 , k = 0.051 : Manchas locas 
  // F = 0.014, k = 0.047 :  (reaccion de los rusos )
  
void settings() {
  K = 0.0565f ;
  F = 0.03f ;
  size(3840/2 , 2160/2, P2D);
  smooth(0);
}

void setup() {
  
  nuevaTextura = (PGraphics2D) createGraphics(width, height, P2D);
  nuevaTextura.beginDraw();
  // Configura tu nueva textura según tus necesidades
  nuevaTextura.endDraw();
  
  //videoExport = new VideoExport(this, "BZkhfkfhkd.mp4");
  //videoExport.startMovie();
  
  // pixelflow context
  context = new DwPixelFlow(this);
  
  // 1) 32 bit per channel
  tex_grayscott.resize(context, GL2.GL_RG32F, width, height, GL2.GL_RG, GL2.GL_FLOAT, GL2.GL_NEAREST, 2, 4);
 
  // glsl shader
  shader_grayscott = context.createShader("data/grayscott.frag");
  shader_render    = context.createShader("data/render.frag");
      
  // init
  tex_render = (PGraphics2D) createGraphics(width, height, P2D);
  tex_render.smooth(0);
  tex_render.beginDraw();
  tex_render.textureSampling(2);
  tex_render.blendMode(REPLACE);
  tex_render.clear();
  tex_render.noStroke();
  tex_render.background(0x00FF0000);
  tex_render.fill      (0x0000FF00);
  tex_render.noStroke();
  
  // Generar la distribucion inicial 
  for(int i = 0 ; i < 100 ;i++){
    tex_render.ellipse(random(width),random(height), 5, 5);
  }
  
  tex_render.endDraw();

  DwFilter.get(context).copy.apply(tex_render, tex_grayscott.src);
  
  frameRate(1000);
}

void reactionDiffusionPass(){
  context.beginDraw(tex_grayscott.dst);
  
  
  shader_grayscott.begin();
  shader_grayscott.uniform1f     ("dA"    , 1.0f  );
  shader_grayscott.uniform1f     ("dB"    , 0.5f  );
  shader_grayscott.uniform1f     ("feed"  , F);
  shader_grayscott.uniform1f     ("kill"  , K );
  shader_grayscott.uniform1f     ("dt"    , 1f    );
  shader_grayscott.uniform2f     ("wh_rcp", (1f/width), (1f/height) );
  shader_grayscott.uniform2f     ("wh_rcp2", 0.3 ,(1f/height) );
      
 
  shader_grayscott.uniformTexture("tex", tex_grayscott.src);

  
  shader_grayscott.drawFullScreenQuad();
  shader_grayscott.end();
  
  context.endDraw("reactionDiffusionPass()"); 
  
  tex_grayscott.swap();
}

void draw() {
  
  // multipass rendering, ping-pong 
  
  context.begin();
  
  for(int i = 0; i < 15; i++){
    reactionDiffusionPass();
  }

 
  context.beginDraw(tex_render);
    
  shader_render.begin();
  shader_render.uniform2f     ("wh_rcp", (1f/width), (1f/height));
  shader_render.uniformTexture("tex"   , tex_grayscott.src);
  shader_render.drawFullScreenQuad();
  shader_render.end();
  context.endDraw("render()"); 
  context.end();
   
  blendMode(REPLACE);
  
  image(tex_render, 0, 0);
  //videoExport.saveFrame();
  
}

/*
void keyPressed() {
  if (key == 'q') {
    videoExport.endMovie();
    exit();
  }
}
*/
