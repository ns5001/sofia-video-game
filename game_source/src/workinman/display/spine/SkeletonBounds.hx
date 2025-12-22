package workinman.display.spine;

import workinman.display.spine.attachments.BoundingBoxAttachment;

class SkeletonBounds {

	private var polygonPool:Array<Polygon>;
	public var boundingBoxes:Array<BoundingBoxAttachment>;
	public var polygons:Array<Polygon>;
	public var minX:Float;
	public var minY:Float;
	public var maxX:Float;
	public var maxY:Float;

	public function new() {
		polygonPool = new Array<Polygon>();
		boundingBoxes = new Array<BoundingBoxAttachment>();
		polygons = new Array<Polygon>();
	}

	public function dispose() : Void
	{
		for(b in boundingBoxes) {
			if(b != null) { b.dispose(); }
		}
		boundingBoxes = null;
		for(p in polygons) {
			if(p != null) { p.dispose(); }
		}
		polygons = null;
		for(p in polygonPool) {
			if(p != null) { p.dispose(); }
		}
		polygonPool = null;
	}

	public function update (skeleton:Skeleton, updateAabb:Bool) : Void {
		var slots:Array<Slot> = skeleton.slots;
		var slotCount:Int = slots.length;
		var x:Float = skeleton.x, y:Float = skeleton.y;

		boundingBoxes = new Array<BoundingBoxAttachment>();
		for (polygon in polygons)
			polygonPool[polygonPool.length] = polygon;
		polygons = new Array<Polygon>();

		var polygon:Polygon;
		for(i in 0...slotCount) {
			var slot:Slot = slots[i];
			var boundingBox:BoundingBoxAttachment = null;
			if(Std.is(slot.attachment, BoundingBoxAttachment)) { boundingBox = cast(slot.attachment, BoundingBoxAttachment); }
			if (boundingBox == null) continue;
			boundingBoxes[boundingBoxes.length] = boundingBox;

			var poolCount:Int = polygonPool.length;
			if (poolCount > 0) {
				polygon = polygonPool[poolCount - 1];
				polygonPool.splice(poolCount - 1, 1);
			} else
				polygon = new Polygon();
			polygons[polygons.length] = polygon;

			boundingBox.computeWorldVertices(x, y, slot.bone, polygon.vertices);
		}

		if (updateAabb) aabbCompute();
	}

	private function aabbCompute () : Void {
		var minX:Float = MathUtils.MAX_INT;
		var minY:Float = MathUtils.MAX_INT;
		var maxX:Float = MathUtils.MIN_INT;
		var maxY:Float = MathUtils.MIN_INT;
		for(i in 0...polygons.length) {
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
		}
		this.minX = minX;
		this.minY = minY;
		this.maxX = maxX;
		this.maxY = maxY;
	}


	/** Returns true if the axis aligned bounding box contains the point. */
	public function aabbContainsPoint (x:Float, y:Float) : Bool {
		return x >= minX && x <= maxX && y >= minY && y <= maxY;
	}

	/** Returns true if the axis aligned bounding box Intersects the line segment. */
	public function aabbIntersectsSegment (x1:Float, y1:Float, x2:Float, y2:Float) : Bool {
		if ((x1 <= minX && x2 <= minX) || (y1 <= minY && y2 <= minY) || (x1 >= maxX && x2 >= maxX) || (y1 >= maxY && y2 >= maxY))
			return false;
		var m:Float = (y2 - y1) / (x2 - x1);
		var y:Float = m * (minX - x1) + y1;
		if (y > minY && y < maxY) return true;
		y = m * (maxX - x1) + y1;
		if (y > minY && y < maxY) return true;
		var x:Float = (minY - y1) / m + x1;
		if (x > minX && x < maxX) return true;
		x = (maxY - y1) / m + x1;
		if (x > minX && x < maxX) return true;
		return false;
	}

	/** Returns true if the axis aligned bounding box Intersects the axis aligned bounding box of the specified bounds. */
	public function aabbIntersectsSkeleton (bounds:SkeletonBounds) : Bool {
		return minX < bounds.maxX && maxX > bounds.minX && minY < bounds.maxY && maxY > bounds.minY;
	}

	/** Returns the first bounding box attachment that contains the point, or null. When doing many checks, it is usually more
	 * efficient to only call this method if {@link #aabbContainsPoint(float, float)} returns true. */
	public function containsPoint (x:Float, y:Float) : BoundingBoxAttachment {
		for(i in 0...polygons.length)
			if (polygons[i].containsPoint(x, y)) { return boundingBoxes[i]; }
		return null;
	}

	/** Returns the first bounding box attachment that contains the line segment, or null. When doing many checks, it is usually
	 * more efficient to only call this method if {@link #aabbIntersectsSegment(float, float, float, float)} returns true. */
	public function intersectsSegment (x1:Float, y1:Float, x2:Float, y2:Float) : BoundingBoxAttachment {
		for(i in 0...polygons.length)
			if (polygons[i].intersectsSegment(x1, y1, x2, y2)) return boundingBoxes[i];
		return null;
	}

	public function getPolygon (attachment:BoundingBoxAttachment) : Polygon {
		var index:Int = boundingBoxes.indexOf(attachment);
		return index == -1 ? null : polygons[index];
	}

	public var width (get, never) : Float;
	private function get_width () : Float {
		return maxX - minX;
	}

	public var height (get, never) : Float;
	private function get_height () : Float {
		return maxY - minY;
	}
}
