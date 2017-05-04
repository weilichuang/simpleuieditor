// =================================================================================================
//
//	Starling Framework
//	Copyright Gamua GmbH. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.text
{
    import flash.utils.Dictionary;

    import starling.display.Image;
    import starling.textures.Texture;

    /** A BitmapChar contains the information about one char of a bitmap font.
     *  <em>You don't have to use this class directly in most cases. 
     *  The TextField class contains methods that handle bitmap fonts for you.</em>    
     */ 
    public class BitmapChar
    {
		/** The texture of the character. */
		public var texture:Texture;
		
		/** The unicode ID of the char. */
        public var charID:int;
		
		/** The number of points to move the char in x direction on character arrangement. */
		public var xOffset:Number;
		
		/** The number of points to move the char in y direction on character arrangement. */
		public var yOffset:Number;
		
		/** The number of points the cursor has to be moved to the right for the next char. */
		public var xAdvance:Number;
		
        private var _kernings:Dictionary;
        
        /** Creates a char with a texture and its properties. */
        public function BitmapChar(id:int, texture:Texture, 
                                   xOffset:Number, yOffset:Number, xAdvance:Number)
        {
            this.charID = id;
			this.texture = texture;
			this.xOffset = xOffset;
			this.yOffset = yOffset;
			this.xAdvance = xAdvance;
            _kernings = null;
        }
        
        /** Adds kerning information relative to a specific other character ID. */
        public function addKerning(charID:int, amount:Number):void
        {
            if (_kernings == null)
                _kernings = new Dictionary();
            
            _kernings[charID] = amount;
        }
        
        /** Retrieve kerning information relative to the given character ID. */
        public function getKerning(charID:int):Number
        {
            if (_kernings == null || _kernings[charID] == undefined) return 0.0;
            else return _kernings[charID];
        }
        
        /** Creates an image of the char. */
        public function createImage():Image
        {
            return new Image(texture);
        }

        /** The width of the character in points. */
        public function get width():Number { return texture.width; }
        
        /** The height of the character in points. */
        public function get height():Number { return texture.height; }
    }
}