package workinman.display.spine.platform.flambe;

import workinman.display.spine.attachments.RegionAttachment;

class SkeletonRegions {

	public var width(get, never):Float;
	public var height(get, never):Float;

	public var regions			: Array<RegionAttachment>;
	public var polygons			: Array<Polygon>;
	private var polygonPool		: Array<Polygon>;
	private var _renderer		: SkeletonAnimation;

	public var minX:Float;
	public var minY:Float;
	public var maxX:Float;
	public var maxY:Float;

	public function new(pRender:SkeletonAnimation) {
		regions = new Array<RegionAttachment>();
		polygonPool = new Array<Polygon>();
		polygons = new Array<Polygon>();
		_renderer = pRender;
	}

	public function dispose() : Void
	{
		regions = null;
		_renderer = null;
		for(p in polygons) {
			if(p != null) { p.dispose(); }
		}
		polygons = null;
		for(p in polygonPool) {
			if(p != null) { p.dispose(); }
		}
		polygonPool = null;
	}

	public function update(skeleton:Skeleton, updateAabb:Bool, pScaleX:Float, pScaleY:Float):Void {
		var x:Float = skeleton.x;
		var y:Float = skeleton.y;
		for (polygon in polygons)
			polygonPool.push(polygon);
		polygons = new Array<Polygon>();
		regions = new Array<RegionAttachment>();

		var drawOrder:Array<Slot> = skeleton.drawOrder;
		for (i in 0 ... drawOrder.length) {
			var slot:Slot = drawOrder[i];
			if (slot.attachment == null) continue;
			if(Std.is(slot.attachment, RegionAttachment)) {
				var regionAttachment:RegionAttachment = cast(slot.attachment, RegionAttachment);
				var region:RegionSprite = _renderer.regions.get(regionAttachment);
				if(_renderer.sprites.get(region.regionAttachment).visible == false) { continue; }
				if(slot.attachment != region.regionAttachment) { continue; }

				regions.push(region.regionAttachment);
				var polygon:Polygon;
				if (polygonPool.length > 0)
					polygon = polygonPool.pop();
				else polygon = new Polygon();

				polygons.push(polygon);
				region.regionAttachment.computeWorldVertices(x, y, region.slot.bone, polygon.vertices);

				var ii:Int = 0;
				var nn:Int = polygon.vertices.length;
				while(ii < nn) {
					polygon.vertices[ii] *= pScaleX;
					ii+=2;
				}
				var ii:Int = 1;
				var nn:Int = polygon.vertices.length;
				while(ii < nn) {
					polygon.vertices[ii] *= pScaleY;
					ii+=2;
				}

				regionAttachment = null;
				region = null;
			}
		}
		drawOrder = null;
		regions.reverse();
		polygons.reverse();

		if (updateAabb)
			aabbCompute();
	}

	function aabbCompute():Void {
		var minX:Float = workinman.display.spine.MathUtils.MAX_INT;
		var minY:Float = workinman.display.spine.MathUtils.MAX_INT;
		var maxX:Float = workinman.display.spine.MathUtils.MIN_INT;
		var maxY:Float = workinman.display.spine.MathUtils.MIN_INT;
		var i:Int = 0;
		var n:Int = polygons.length;
		while(i < n) {
			var polygon:Polygon = polygons[i];
			var vertices:Array<Float> = polygon.vertices;
			var ii:Int = 0;
			var nn:Int = vertices.length;
			while(ii < nn) {
				var x:Float = vertices[ii];
				var y:Float = vertices[ii + 1];
				minX = Math.min(minX, x);
				minY = Math.min(minY, y);
				maxX = Math.max(maxX, x);
				maxY = Math.max(maxY, y);
				ii += 2;
			}
			i++;
		}
		this.minX = minX;
		this.minY = minY;
		this.maxX = maxX;
		this.maxY = maxY;
	}

	/** Returns true if the axis aligned bounding box contains the point. */
	public function aabbContainsPoint(x:Float, y:Float):Bool {
		return x >= minX && x <= maxX && y >= minY && y <= maxY;
	}

	/** Returns true if the axis aligned bounding box intersects the line segment. */
	public function aabbIntersectsSegment(x1:Float, y1:Float, x2:Float, y2:Float):Bool {
		if ((x1 <= minX && x2 <= minX) || (y1 <= minY && y2 <= minY) || (x1 >= maxX && x2 >= maxX) || (y1 >= maxY && y2 >= maxY))
			return false;
		var m:Float = (y2 - y1) / (x2 - x1);
		var y:Float = m * (minX - x1) + y1;
		if (y > minY && y < maxY)
			return true;
		y = m * (maxX - x1) + y1;
		if (y > minY && y < maxY)
			return true;
		var x:Float = (minY - y1) / m + x1;
		if (x > minX && x < maxX)
			return true;
		x = (maxY - y1) / m + x1;
		if (x > minX && x < maxX)
			return true;
		return false;
	}

	/** Returns true if the axis aligned bounding box intersects the axis aligned bounding box of the specified bounds. */
	public function aabbIntersectsSkeleton(bounds:SkeletonBounds):Bool {
		return minX < bounds.maxX && maxX > bounds.minX && minY < bounds.maxY && maxY > bounds.minY;
	}

	/** Returns the first bounding box attachment that contains the point, or null. When doing many checks, it is usually more
	 * efficient to only call this method if {@link #aabbContainsPoint(float, float)} returns true. */
	public function containsPoint(x:Float, y:Float):RegionAttachment {
		var i:Int = 0;
		var n:Int = polygons.length;
		while(i < n) {
			if (polygons[i].containsPoint(x, y))
				return regions[i];
			i++;
		}
		return null;
	}

	/** Returns the first bounding box attachment that contains the line segment, or null. When doing many checks, it is usually
	 * more efficient to only call this method if {@link #aabbIntersectsSegment(float, float, float, float)} returns true. */
	public function intersectsSegment(x1:Float, y1:Float, x2:Float, y2:Float):RegionAttachment {
		var i:Int = 0;
		var n:Int = polygons.length;
		while(i < n) {
			if (polygons[i].intersectsSegment(x1, y1, x2, y2))
				return regions[i];
			i++;
		}
		return null;
	}

	public function getPolygon(attachment:RegionAttachment):Polygon {
		var index:Int = regions.indexOf(attachment);
		return index == -(1) ? null:polygons[index];
	}

	private function get_width():Float {
		return maxX - minX;
	}

	private function get_height():Float {
		return maxY - minY;
	}
}
