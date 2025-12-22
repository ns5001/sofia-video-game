package workinman.display.spine.platform.flambe;

import workinman.display.spine.attachments.Attachment;
import workinman.display.spine.attachments.RegionAttachment;
import workinman.display.spine.attachments.MeshAttachment;
import workinman.display.spine.attachments.WeightedMeshAttachment;
import workinman.display.spine.attachments.BoundingBoxAttachment;

class SkeletonSprite extends Sprite {

	public var skeleton			: Skeleton;

	private var _holder 		: Sprite;
	private var _sprites		: Map<Attachment, WrapperSprite>;
	private var _regions		: Map<RegionAttachment, RegionSprite>;
	private var _meshes			: Map<MeshAttachment, MeshSprite>;
	private var _weightedMeshes	: Map<WeightedMeshAttachment, WeightedMeshSprite>;
	private var _flagRenderBoxes: Bool;

	public var colorBoundingBox : Int = 0xFF0000;
	public var colorRegionBox : Int = 0x00FF00;

	public function new (skeletonData:SkeletonData, renderBoxes:Bool = false) {
		super(null);

		 _holder = new Sprite(null);

		Bone.yDown = true;

		skeleton = new Skeleton(skeletonData);
		skeleton.updateWorldTransform();

		_sprites = new Map<Attachment, WrapperSprite>();
		_regions = new Map<RegionAttachment, RegionSprite>();
		_meshes = new Map<MeshAttachment, MeshSprite>();
		_weightedMeshes = new Map<WeightedMeshAttachment, WeightedMeshSprite>();

		_flagRenderBoxes = renderBoxes;
		drawSprites(true);

		addChild(_holder);
	}

    public override function dispose ()
    {
    	if(_holder != null) { removeChild(_holder); }
       	super.dispose();

	    if(skeleton != null) { skeleton.dispose(); }
        skeleton = null;

    	if(_holder != null) { _holder.dispose(); }
        _holder = null;

		// following is disposed in disposeChildren
        _sprites = null;
		_regions = null;
        _meshes = null;
        _weightedMeshes = null;
    }

	public var regions(get, never) : Map<RegionAttachment, RegionSprite>;
	public function get_regions() : Map<RegionAttachment, RegionSprite> { return _regions; }

	public var sprites(get, never) : Map<Attachment, WrapperSprite>;
	public function get_sprites() : Map<Attachment, WrapperSprite> { return _sprites; }

	private override function _draw( g:Graphics ) : Void
	{
		drawSprites(false);
	}

	public function drawSprites(pDrawAll:Bool)
	{
		for(sprite in _sprites) {
        	sprite.visible = false;
        }

		var drawOrder:Array<Slot> = skeleton.drawOrder;
		if(pDrawAll) {
			drawOrder = skeleton.slots;
		}
		for (i in 0 ... drawOrder.length) {
			var slot:Slot = drawOrder[i];
			if (slot.attachment == null) continue;
			if(Std.is(slot.attachment, RegionAttachment)) {
				var regionAttachment:RegionAttachment = cast(slot.attachment, RegionAttachment);
				if (regionAttachment != null) {
					// get sprite
					var wrapper:WrapperSprite = _sprites.get(regionAttachment);

					// create sprite if it doesn't exist
	                if(wrapper == null)
	                {
						// Add image
	                    var partSprite:RegionSprite= new RegionSprite(regionAttachment, slot);

						// Add wrapper
	                    wrapper = new WrapperSprite();
	                    var part:Sprite = wrapper;
						part.addChild(partSprite);

	                    if(_flagRenderBoxes) {
							_renderBoxes(slot, regionAttachment, part);
						}

						// save
	                    _sprites.set(regionAttachment, wrapper);
						_regions.set(regionAttachment, partSprite);
	                    _holder.addChild(part);
					}

					// Update draw order
					var sprite:Sprite = _sprites.get(regionAttachment);
	                _holder.addChild(sprite);

					// Update bone
					var bone:Bone = slot.bone;
					var flipX:Int = skeleton.flipX ? -1 : 1;
					var flipY:Int = skeleton.flipY ? -1 : 1;

					// Update sprite
					wrapper.visible = true;
					wrapper.a = bone.a;
					wrapper.b = bone.b;
					wrapper.c = bone.c;
					wrapper.d = bone.d;
					wrapper.e = bone.worldX;
					wrapper.f = bone.worldY;

					// Update alpha
					wrapper.alpha = skeleton.a * slot.a * regionAttachment.a;

					//TODO update color
					// blend mode doesn't work in flambe
					var r:Float = skeleton.r * slot.r * regionAttachment.r;
					var g:Float = skeleton.g * slot.g * regionAttachment.g;
					var b:Float = skeleton.b * slot.b * regionAttachment.b;
					var color:String = "0x" + toHexColor(Math.floor(r * 255)) + toHexColor(Math.floor(g * 255)) + toHexColor(Math.floor(b * 255));
					_regions.get(regionAttachment).color = Std.parseInt(color);
				}
				regionAttachment = null;
			} else if(Std.is(slot.attachment, MeshAttachment)) {
				var meshAttachment:MeshAttachment = cast(slot.attachment, MeshAttachment);
				if (meshAttachment != null) {
					// get sprite
					var wrapper:WrapperSprite = _sprites.get(meshAttachment);

					// create sprite if it doesn't exist
	                if(wrapper == null)
	                {
						// Add image
	                    var partSprite:MeshSprite= new MeshSprite(meshAttachment, slot, _flagRenderBoxes);

						// Add wrapper
	                    wrapper = new WrapperSprite();
						var part:Sprite = wrapper;
	                    part.addChild(partSprite);

						// save
	                    _sprites.set(meshAttachment, wrapper);
						_meshes.set(meshAttachment, partSprite);
	                    _holder.addChild(part);
					}

					// Update draw order
					var sprite:Sprite = _sprites.get(meshAttachment);
	                _holder.addChild(sprite);

					var worldVertices:Array<Float> = meshAttachment.updateWorldVertices(slot, true);
					_meshes.get(meshAttachment).worldVertices = worldVertices;
					wrapper.visible = true;

					// set alpha
					wrapper.alpha = skeleton.a * slot.a * meshAttachment.a;
				}
				meshAttachment = null;
			} else if(Std.is(slot.attachment, WeightedMeshAttachment)) {
				var meshAttachment:WeightedMeshAttachment = cast(slot.attachment, WeightedMeshAttachment);
				if (meshAttachment != null) {
					// get sprite
					var wrapper:WrapperSprite = _sprites.get(meshAttachment);

					// create sprite if it doesn't exist
	                if(wrapper == null)
	                {
						// Add image
	                    var partSprite:WeightedMeshSprite= new WeightedMeshSprite(meshAttachment, slot);

						// Add wrapper
	                    wrapper = new WrapperSprite();
						var part:Sprite = wrapper;
						part.addChild(partSprite);

						// save
	                    _sprites.set(meshAttachment, wrapper);
						_weightedMeshes.set(meshAttachment, partSprite);
	                    _holder.addChild(part);
					}

					var worldVertices:Array<Float> = ArrayUtils.allocFloat(meshAttachment.uvs.length);
					meshAttachment.computeWorldVertices(skeleton.x, skeleton.y, slot, worldVertices);
					_weightedMeshes.get(meshAttachment).worldVertices = worldVertices;

					// Update draw order
					var sprite:Sprite = _sprites.get(meshAttachment);
	                _holder.addChild(sprite);

					wrapper.visible = true;

					// set alpha
					wrapper.alpha = skeleton.a * slot.a * meshAttachment.a;
				}
				meshAttachment = null;
			}
		}
		drawOrder = null;
	}

	private function _renderBoxes(slot:Slot, regionAttachment:RegionAttachment, part:Sprite) : Void
	{
		var fill:FillSprite;
		var polygon:Polygon = new Polygon();

		var flipX:Int = skeleton.flipX ? -1 : 1;
		var flipY:Int = skeleton.flipY ? -1 : 1;
		var angle:Float = slot.bone.worldRotationX * flipX * flipY;
		angle = angle * -Math.PI / 180;

		// Add bounding box
        for (i in 0...skeleton.slots.length) {
			var slot:Slot = skeleton.slots[i];
			if(skeleton.data.defaultSkin.attachments[i] != null) {
				for(attachment in skeleton.data.defaultSkin.attachments[i]) {
					var boundingBox:BoundingBoxAttachment = try cast(attachment, BoundingBoxAttachment) catch(e:Dynamic) null;
					if (boundingBox == null) { continue; }

					if(boundingBox.name == regionAttachment.name) {
						// Get vertices
						var ii:Int = 0;
						var nn:Int = boundingBox.vertices.length;
						var vertices:Array<Float> = new Array<Float>();
						polygon.vertices.splice(boundingBox.vertices.length, polygon.vertices.length - boundingBox.vertices.length);
						boundingBox.computeWorldVertices(skeleton.x, skeleton.y, slot.bone, polygon.vertices);

						while(ii < nn) {
							var id1:Int = ii;
							var id2:Int = ii + 2;
							if(ii == nn - 2) { id2 = 0; }

							// translate vertices based on wrapper
							var x1:Float = polygon.vertices[id1] - slot.bone.worldX;
							var y1:Float = polygon.vertices[id1 + 1] - slot.bone.worldY;
							var x2:Float = polygon.vertices[id2] - slot.bone.worldX;
							var y2:Float = polygon.vertices[id2 + 1] - slot.bone.worldY;

							// rotate vertices based on wrapper
							var oldX:Float = x1;
							var oldY:Float = y1;
							x1 = Math.cos(angle) * (oldX - 0) - Math.sin(angle) * (oldY - 0) + 0;
							y1 = Math.sin(angle) * (oldX - 0) + Math.cos(angle) * (oldY - 0) + 0;

							oldX = x2;
							oldY = y2;
							x2 = Math.cos(angle) * (oldX - 0) - Math.sin(angle) * (oldY - 0) + 0;
							y2 = Math.sin(angle) * (oldX - 0) + Math.cos(angle) * (oldY - 0) + 0;

							// draw line
							var height:Float = Math.abs(Math.sqrt(((x1-x2) * (x1-x2)) + ((y1-y2) * (y1-y2))));
							var rot:Float = Math.atan2((y2 - y1), (x2 - x1)) * 180 / Math.PI - 90;
							fill = new FillSprite({color:colorBoundingBox, sizeX:5, sizeY:Math.floor(height)});
							fill.x = x1;
							fill.y = y1;
							fill.rotation = rot;
							part.addChild(fill);

							ii += 2;
						}
					}
				}
			}
		}


		// Add region box
		var polygon:Polygon = new Polygon();
		regionAttachment.computeWorldVertices(skeleton.x, skeleton.y, slot.bone, polygon.vertices);
		var ii:Int = 0;
		var nn:Int = polygon.vertices.length;
		var fill:FillSprite;
		while(ii < nn) {
			var id1:Int = ii;
			var id2:Int = ii + 2;
			if(ii == nn - 2) { id2 = 0; }

			// translate vertices based on wrapper
			var x1:Float = polygon.vertices[id1] - slot.bone.worldX;
			var y1:Float = polygon.vertices[id1 + 1] - slot.bone.worldY;
			var x2:Float = polygon.vertices[id2] - slot.bone.worldX;
			var y2:Float = polygon.vertices[id2 + 1] - slot.bone.worldY;

			// rotate vertices based on wrapper
			var oldX:Float = x1;
			var oldY:Float = y1;
			x1 = Math.cos(angle) * (oldX - 0) - Math.sin(angle) * (oldY - 0) + 0;
			y1 = Math.sin(angle) * (oldX - 0) + Math.cos(angle) * (oldY - 0) + 0;

			oldX = x2;
			oldY = y2;
			x2 = Math.cos(angle) * (oldX - 0) - Math.sin(angle) * (oldY - 0) + 0;
			y2 = Math.sin(angle) * (oldX - 0) + Math.cos(angle) * (oldY - 0) + 0;

			// draw line
			if(slot.bone.worldScaleX < 0) {
				// offset bounding box if scale is negative
				y1 *= -1;
				y2 *= -1;
			}
			var height:Float = Math.abs(Math.sqrt(((x1-x2) * (x1-x2)) + ((y1-y2) * (y1-y2))));
			var rot:Float = Math.atan2((y2 - y1), (x2 - x1)) * 180 / Math.PI - 90;
			fill = new FillSprite({color:colorRegionBox, sizeX:2, sizeY:Math.floor(height)});
			fill.x = x1;
			fill.y = y1;
			fill.rotation = rot;
			part.addChild(fill);

			ii += 2;
		}
		fill = null;
		polygon = null;
	}

	function toHexColor(n:Int):String {
		 n = cast Math.max(0,Math.min(n,255));
		 return "0123456789ABCDEF".charAt(Math.floor((n-n%16)/16)) + "0123456789ABCDEF".charAt(Math.floor(n%16));
	}
}
