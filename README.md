# ahk2 utilities, libs, prototypes, and exploration
A mix of mostly functional tools authord by others, with my own adaptations and a few of my own. Be aware that some are in flux, while others need significant work to realize intented feature sets.  I have a tendancy to jump around between efforts a fair amount.  Anyway please use or improve if you like, or if appropriate certainly point out where I have gone wrong. I'm always open to feedback!  

Also, it's certainly possible that I missed a lib here or there, let me know if I did and I'll dig it up.


## Libs
- classhelper.ahk: Misc helper functions for classes
- webServerClient - modified inital project to fit peranl needs at the time, mostly original work of authors. locally hosted web server, which I utilized along with ngrok.ahk to exlplore basic webhook functionality with Macdroid on my phone, with success!
- Icons: jsut a collection of icon I have been using with image buttons. Starting to focus mostly on material-icons
- iconhelper.ahk: convert svg to png with some file back-up support, no frills 
- area.ahk: started out as a rather straight-forward screen clipping utillity with some simple overlay creation features. It's still those things, but as I started to enhance I couldn't settle on which direction to go with it, as a result it's a little conveluted here and         there.  I have, however, been using it sucessfully in mupltiple projects for a good while. I am deffinately open to suggestion on this one.  I think with a little direction, refactoring, and clean-up, & TLC it could become a solid tool or at least a base for one.
- Debug.aks: a console for displaying debug output.  One of my earliest efforts, it has some utility I suppose.  It's just that there are better options available at with less overhead.
- DevToolsProtocol_Full.ahk: Only partial realized, functionality.  Had big plans with this one, until I didn't.  Ended up being more of an excercise and learning tool for me as I explored the class object more.
- disk.ahk: simple disk operations wrapper, nothing speacial, mostly preference with a few quality of life features.
- EventHandler.ahk: Handy EventEmitter class I now use with just about every class I write these days.  Minor edits by me, major kudso to the Author: neovis!
- fileProps.ahk: exposes file properties, very useful given the need
- googleDrive.ahk: just handles connecting to a google drive
- RandomBeizer.ahk: Moves the mouse through a random B�zier path.  Definately not my work, but I have used it alot since I found it.  Would like to find additional libs with similar functionality.
- Xhr.ahk: simple wrapper class. nothing new.
- Whr.ahk: simple little wrapper class, nothing new.
- WinUserHeader.ahk: I had such grand inital designs for this one too, just like DevToolsProtocol_Full.ahk. I worked on them both in in support of wv2Client.ahk
- wv2Client.ahk: just what it sounds like, the intent here was to build a framework allowing for standarized seemless sever/client interaction.  Still interested in this concept, more planning is need I think.  Another exploration effort on my part.
- Utility.ahk: Collection of various utilities I use frequently, and is a lib I use pretty much by default in most new projects.
