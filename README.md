# Basic Metal 2D

Apple announced iPad Pro and Apple Pencil in 2015 summer.  I was wondering if I could develop a graphics type of app based on those devices.  Then I was wondering which technologies I should go for.   I remembered that Apple said Metal is 10 times faster than Open GL ES in WWDC video.  I know I may be the only one who believes such story on this planet, and I started look into Metal from that point.

I have some experiences developing a OpenGL ES 1.1 based graphics app once, but it does not require to write shaders.  I figured out learning Metal Programming is actually harder than I thought.  Shader requires extensive knoweldge about mathmatical computation, and Metal requires extensive knowledge about Graphics Pipleline and others.

I started searching some good example codes to be a boilerplating project for 2D Metal app.  But many of them are wrote for very specific purpose such as demonstrate how to write shader, or to demonstrate sophisticated features in GPU and so on.  They are not suitable for a boilerplate project in my eyes.

# Sample code for boilerplating

So I made a decision that the goal of my sample project to be the boilerplating project for Meatl 2D.  It took a while bu here it is.  Basic Metal 2D sample code provides some very basic fanctionalities such as displaying 2D image with panning and pinching operation. Here is the screen shot.

![Screenshot](https://qiita-image-store.s3.amazonaws.com/0/65634/d95141e2-65b9-a1e4-299a-d2baf9333964.jpeg)

# Architecture

Since Metal Programming is pretty extensive, I broke it down to following components.  So client code does not have to get too much involved for the rendering process, rather focus on modeling. 
 
### Shader

Shader code can be executed on GPU.  There are vertex shaders and fragment shaders.  This must be designed very tightly with `Renderer`.

### Renderer

`Renderer` abstructs `RenderPipelineDescriptor` and `RenderPipelineState`. It's subclass actually needs to provide Render Pipeline, and client code does not have to know much about Render Pipeline as long as it is called through API.


### Renderable

`Renderable` represents object model of `Renderer`.  `Renderable` subclass needs to be designed tightly with `Renderer`. 


### RenderContext

There are so many intermediate objects involved for the actual rendering process.  So `RenderContext` aggregates all direct or indirect objects necessary to the rendering process.  `RenderContext` also manage parent-child model transforming information while rendering is being process.


# Write your own custom shader

If you like to add some your own shaders, you will need to provide your own Shader, `Renderer` and `Renderable ` in a whole set.  Please refer `ImageRenderer` and `ImageNode`.

# TO DO List

- Touch Stroke Shader
- Uniform information enhancement
- UIScroll view like usability
- Architecture improvement
- naming?


