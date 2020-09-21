#  Mobile Assignment aka Doodler

## Architecture

### Views

The app consists of two main views: 
*Drawing Display
A collection view of all the drawings created.

*Edit Drawing
The view to create and edit the drawing

### Model

Each drawing is represented by a `Drawing` object. The Drawing has a `startDate`, the creation time of the drawing; an `endDate`, the time of the most recent edit; the Firebase `id` given to the object and an array of all the `Marks`.

The `Mark` object is how I keep track of the marks drawn. For each path of the finger on the device,  a mark keeps track of the `color`, `thickness`, and whether or not the mark has been `erased`. To keep the points drawn I map the time recorded for the point as `clock_t` to a CGPoint representation of the point where the touch happens at that time. This dictionary is then stored as the mark. 

To erase marks, I made the decision to erase the entire path crossed by the erase brush. This was bwecause of how the path is drawn. Alternatively, I could have had the eraser be a separate pen that always used the color of the background and then drew over the other layers. At this time, I don't think that would have worked as well, as the lines aren't as smooth as they can be. 

### Controllers

The controller listens for touches on the screen and updates the view accordingly, with the current drawing color and line thickness. It instructs the currently editing drawing to add and erase marks accordingly. 

The Drawing display controller orders the drawings, most recent first, and displays a cropped version of the thumbnail, creation date, and time in seconds.

To delete a drawing, I implemented a context menu so you long press on the drawing. 

## Improvments

* The current drawing size is most of the size of the screen of whatever device the user is using. With more time, I would like to have selectable aspect ratios to have a more uniform experience across all devices.
* Knowing the aspect ratio and explicit width and height of the drawing would allow the thumbnails to adjust accordingly and preview the entire drawing
* The lines are smooth enough, while drawing at least. But, they aren't saved as smooth as I'd like them to be. To fix this I would want to do something akin to this: https://dzone.com/articles/smooth-drawing-for-ios-in-swift-with-hermite-splin with some interpolation of the points to smooth out the drawing. 
* Currently, the "replay" drawing animation does not happen in real time that the drawing happened. Each mark could be staged so that they are drawn in order. This implementation also does not show erased lines drawn or being erased. To fix this, I would set dependencies for each block operation on the one prior, and keep track of erase paths as well as mark paths. 
* While the Drawings are stored in Firestore, they are not unique to device or user. To fix this, adding a signup and login page would allow users to have their own drawings.
* Using the `UIColorWell` class to let the user pick custom colors means the app only runs on iOS 14 and later. To allow for more backwards compatability I would either want to define a static set of colors for the drawing to use or a third party library for picking colors.
* I wanted to have the ability to name drawings, which would just be stored as a string and displayed under the thumbnails. 
* Time to draw is displayed in floating point seconds. I would clean this up by converting to minutes and hours where applicable 

