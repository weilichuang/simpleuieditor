/*
Feathers
Copyright 2012-2016 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls.supportClasses
{
	import feathers.core.IFeathersControl;
	
	[ExcludeClass]
	public interface IViewPort extends IFeathersControl
	{
		function get visibleWidth():Number;
		function set visibleWidth(value:Number):void;
		function get minVisibleWidth():Number;
		function set minVisibleWidth(value:Number):void;
		function get maxVisibleWidth():Number;
		function set maxVisibleWidth(value:Number):void;
		function get visibleHeight():Number;
		function set visibleHeight(value:Number):void;
		function get minVisibleHeight():Number;
		function set minVisibleHeight(value:Number):void;
		function get maxVisibleHeight():Number;
		function set maxVisibleHeight(value:Number):void;
		
		function get contentX():Number;
		function get contentY():Number;
		
		function get horizontalScrollPosition():Number;
		function set horizontalScrollPosition(value:Number):void;
		function get verticalScrollPosition():Number;
		function set verticalScrollPosition(value:Number):void;
		function get horizontalScrollStep():Number;
		function get verticalScrollStep():Number;
		
		function get requiresMeasurementOnScroll():Boolean;
		
		/**
		 * 目前使用mask之后一些在不可见位置的元素依然在绘制，添加一个方法用来避免绘制不可见元素
		 */
		function refreshMask():void;
	}
}
